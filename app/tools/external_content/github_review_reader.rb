# frozen_string_literal: true

# Public code downloads for submission reviews; never uses Pjord's authenticated API reader.
class ExternalContent::GithubReviewReader < ExternalContent::WebPageReader
  CONTENT_LIMIT = 50_000
  PR_PATH = %r{\A/([^/]+)/([^/]+)/pull/(\d+)(?:/files/?|/|\.diff)?\z}
  BLOB_PATH = %r{\A/([^/]+)/([^/]+)/blob/([^/]+)/(.+)\z}

  def self.support?(uri)
    return false unless uri.is_a?(URI::HTTPS) && uri.userinfo.nil? && uri.port == 443

    (uri.host == 'github.com' && (PR_PATH.match?(uri.path) || BLOB_PATH.match?(uri.path))) ||
      (uri.host == 'raw.githubusercontent.com' && uri.path.match?(%r{\A/[^/]+/[^/]+/[^/]+/.+\z}))
  end

  def initialize(max_body_bytes: 10.megabytes, request_timeout: 15, log_errors: false)
    super
  end

  def fetch(url)
    uri = URI.parse(url.to_s)
    return ExternalContent::UNREADABLE_URL_MESSAGE unless self.class.support?(uri)

    @source_url = uri.to_s
    @diff = uri.host == 'github.com' && PR_PATH.match?(uri.path)
    result = super(download_url(uri))
    return result if result.is_a?(Array) || result.to_s.start_with?("# GitHub Review Source\n")

    ExternalContent::UNREADABLE_URL_MESSAGE
  rescue URI::InvalidURIError
    ExternalContent::UNREADABLE_URL_MESSAGE
  end

  private

  def download_url(uri)
    if @diff
      match = PR_PATH.match(uri.path)
      "https://github.com/#{match[1]}/#{match[2]}/pull/#{match[3]}.diff"
    elsif uri.host == 'github.com'
      match = BLOB_PATH.match(uri.path)
      "https://raw.githubusercontent.com/#{match[1]}/#{match[2]}/#{match[3]}/#{match[4]}"
    else
      uri.query = nil
      uri.fragment = nil
      uri.to_s
    end
  end

  def format_page(url, body)
    raw_body = body.to_s.b
    return ExternalContent::UNREADABLE_URL_MESSAGE if binary_source?(raw_body)

    code = raw_body.dup.force_encoding(Encoding::UTF_8).scrub
    return ExternalContent::UNREADABLE_URL_MESSAGE if @diff && !unified_diff?(code)

    scope = if @diff
              '確認範囲: Files changedの差分とハンク内の文脈のみ。未変更ファイル全体は取得していません。バイナリの内容は確認できません。'
            else
              '確認範囲: このURLのソースコードのみ。リンク先や他のファイルは取得していません。'
            end
    truncation = '切り詰め: 先頭50000文字のみ。残りは未確認です。' if code.length > CONTENT_LIMIT
    <<~TEXT
      # GitHub Review Source
      - Source URL: #{@source_url}
      - Download URL: #{url}
      - #{scope}
      #{truncation}

      #{code.slice(0, CONTENT_LIMIT)}
    TEXT
  end

  def binary_source?(body)
    sample = body.byteslice(0, 8_000).to_s
    return true if sample.include?("\0")

    mime_type = Marcel::MimeType.for(StringIO.new(sample))
    %w[application/pdf application/zip application/x-zip-compressed].include?(mime_type)
  end

  def unified_diff?(code)
    code.start_with?('diff --git ') &&
      (code.match?(/^--- .+\n\+\+\+ .+\n@@ -\d+(?:,\d+)? \+\d+(?:,\d+)? @@/) ||
       code.match?(/^(?:Binary files .+ differ|GIT binary patch|(?:old|new) mode \d+|(?:rename|copy) (?:from|to) .+)$/))
  end
end
