# frozen_string_literal: true

module ExternalContent
  UNREADABLE_URL_MESSAGE = 'リンク先を確認できませんでした。回答にその内容が不可欠でなければ、取得できなかったことには言及しないでください。@mentor にメンションしないでください。'

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
