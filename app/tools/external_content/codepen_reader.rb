# frozen_string_literal: true

class ExternalContent::CodepenReader
  def self.support?(uri)
    uri.is_a?(URI::HTTP) && uri.host == 'codepen.io' && uri.path.match?(%r{\A/[^/]+/pen/[^/]+/?\z})
  end

  def self.fetch(url)
    new.fetch(url)
  end

  def fetch(url)
    uri = URI.parse(url.to_s)
    return 'CodePenの公開Pen URLだけ取得できます。' unless self.class.support?(uri)

    ExternalContent::UNREADABLE_URL_MESSAGE
  rescue URI::InvalidURIError
    'URLの形式が正しくありません。'
  end
end
