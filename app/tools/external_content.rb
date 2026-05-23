# frozen_string_literal: true

module ExternalContent
  def self.fetch(url)
    uri = URI.parse(url.to_s)
    return 'httpまたはhttpsのURLだけ取得できます。' unless uri.is_a?(URI::HTTP)

    if GithubReader.support?(uri)
      GithubReader.fetch(url)
    else
      WebPageReader.fetch(url)
    end
  rescue URI::InvalidURIError
    'URLの形式が正しくありません。'
  end
end
