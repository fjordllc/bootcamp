# frozen_string_literal: true

module ExternalContent
  UNREADABLE_URL_MESSAGE = 'リンク先を確認できませんでした。提出者に聞かず、@mentor にリンク先の確認と対応引き継ぎを依頼してください。'

  def self.fetch(url)
    uri = URI.parse(url.to_s)
    return 'httpまたはhttpsのURLだけ取得できます。' unless uri.is_a?(URI::HTTP)

    if CodepenReader.support?(uri)
      CodepenReader.fetch(url)
    elsif GithubReader.support?(uri)
      GithubReader.fetch(url)
    else
      WebPageReader.fetch(url)
    end
  rescue URI::InvalidURIError
    'URLの形式が正しくありません。'
  end
end
