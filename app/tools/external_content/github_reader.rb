# frozen_string_literal: true

require 'net/http'
require 'uri'

class ExternalContent::GithubReader
  CONTENT_LIMIT = 20_000
  FILES_LIMIT = 30
  def self.support?(uri)
    uri.is_a?(URI::HTTPS) && %w[github.com raw.githubusercontent.com api.github.com].include?(uri.host)
  end

  def self.fetch(url)
    new.fetch(url)
  end

  def fetch(url)
    uri = URI.parse(url.to_s)
    return 'GitHubのURLだけ取得できます。' unless github_host?(uri)

    case uri.host
    when 'raw.githubusercontent.com'
      format_raw_file(url, fetch_url(url))
    when 'github.com'
      fetch_github_url(uri)
    end
  rescue URI::InvalidURIError
    'URLの形式が正しくありません。'
  rescue StandardError => e
    Rails.logger.warn("[ExternalContent::GithubReader] #{url} #{e.class}: #{e.message}")
    'GitHub URLの取得に失敗しました。'
  end

  private

  def fetch_github_url(uri)
    path = uri.path
    case path
    when %r{\A/([^/]+)/([^/]+)/pull/(\d+)\z}
      fetch_pull_request(::Regexp.last_match(1), ::Regexp.last_match(2), ::Regexp.last_match(3), uri.to_s)
    when %r{\A/([^/]+)/([^/]+)/blob/([^/]+)/(.+)\z}
      owner = ::Regexp.last_match(1)
      repository = ::Regexp.last_match(2)
      ref = ::Regexp.last_match(3)
      file_path = ::Regexp.last_match(4)
      format_raw_file(uri.to_s, fetch_url(raw_url(owner, repository, ref, file_path)))
    when %r{\A/([^/]+)/([^/]+)/tree/([^/]+)/?(.*)\z}
      fetch_directory(::Regexp.last_match(1), ::Regexp.last_match(2), ::Regexp.last_match(3), ::Regexp.last_match(4))
    else
      '対応しているGitHub URLは、pull request、blob、tree、rawファイルです。'
    end
  end

  def fetch_pull_request(owner, repository, number, url)
    pull_request = fetch_json(api_url("/repos/#{owner}/#{repository}/pulls/#{number}"))
    files = fetch_json(api_url("/repos/#{owner}/#{repository}/pulls/#{number}/files"))
    return 'Pull Requestを取得できませんでした。' if pull_request.blank? || files.blank?

    head_sha = pull_request.dig('head', 'sha')
    lines = [
      '# GitHub Pull Request',
      "- URL: #{url}",
      "- タイトル: #{pull_request['title']}",
      "- ブランチ: #{pull_request.dig('head', 'ref')}",
      "- ベースブランチ: #{pull_request.dig('base', 'ref')}",
      "- head SHA: #{head_sha}",
      '',
      '## 説明',
      normalize_body(pull_request['body']).presence || 'なし',
      '',
      '## 変更ファイル'
    ]
    lines.concat(files.first(FILES_LIMIT).map { |file| pull_request_file_line(owner, repository, head_sha, file) })
    lines << "- ...ほか #{files.size - FILES_LIMIT} ファイル" if files.size > FILES_LIMIT
    lines << ''
    lines << '必要なら、上記の raw URL をこのツールに渡してファイル全体を確認してください。'
    lines.join("\n")
  end

  def pull_request_file_line(owner, repository, head_sha, file)
    patch = normalize_body(file['patch']).slice(0, 1_500)
    line = "- #{file['filename']} (#{file['status']}, +#{file['additions']} -#{file['deletions']})"
    line += "\n  raw URL: #{raw_url(owner, repository, head_sha, file['filename'])}" if head_sha.present?
    line += "\n  patch:\n#{indent(patch.presence || 'patchなし')}"
    line
  end

  def fetch_directory(owner, repository, ref, path)
    items = fetch_json(api_url("/repos/#{owner}/#{repository}/contents/#{path}?ref=#{ref}"))
    return 'ディレクトリを取得できませんでした。' if items.blank?
    return format_raw_file(items['download_url'], fetch_url(items['download_url'])) if items.is_a?(Hash) && items['type'] == 'file'

    lines = ["# GitHub Directory", "- repository: #{owner}/#{repository}", "- ref: #{ref}", "- path: /#{path}", '', '## entries']
    lines.concat(items.first(FILES_LIMIT).map do |item|
      "- #{item['type']}: #{item['path']} #{item['html_url']}"
    end)
    lines << "- ...ほか #{items.size - FILES_LIMIT} 件" if items.size > FILES_LIMIT
    lines.join("\n")
  end

  def format_raw_file(url, body)
    return 'ファイルを取得できませんでした。' if body.blank?

    <<~TEXT
      # GitHub File
      - URL: #{url}

      ```#{language_name(url)}
      #{normalize_body(body).slice(0, CONTENT_LIMIT)}
      ```
    TEXT
  end

  def fetch_json(url)
    body = fetch_url(url)
    JSON.parse(body) if body.present?
  rescue JSON::ParserError
    nil
  end

  def fetch_url(url)
    Rails.cache.fetch("pjord_product_reviewer/github_context/#{Digest::SHA256.hexdigest(url)}", expires_in: 10.minutes) do
      response = ExternalContent::HttpClient.get(url, headers: github_request_headers)
      response.success? ? response.body : nil
    end
  end

  def api_url(path)
    "https://api.github.com#{path}"
  end

  def raw_url(owner, repository, ref, path)
    "https://raw.githubusercontent.com/#{owner}/#{repository}/#{ref}/#{path}"
  end

  def github_host?(uri)
    self.class.support?(uri)
  end

  def github_request_headers
    headers = { 'User-Agent' => 'fjord-bootcamp-pjord' }
    headers['Authorization'] = "Bearer #{github_token}" if github_token.present?
    headers
  end

  def github_token
    ENV['PJORD_GITHUB_TOKEN'].presence
  end

  def normalize_body(body)
    body.to_s.dup.force_encoding(Encoding::UTF_8).scrub
  end

  def language_name(url)
    extension = File.extname(URI.parse(url).path).delete_prefix('.')
    extension.presence || 'text'
  rescue URI::InvalidURIError
    'text'
  end

  def indent(text)
    text.to_s.lines.map { |line| "  #{line}" }.join
  end
end
