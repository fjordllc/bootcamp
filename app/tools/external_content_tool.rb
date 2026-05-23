# frozen_string_literal: true

class ExternalContentTool < RubyLLM::Tool
  description 'URLの先にある内容を確認する。GitHubのPR・コード・ディレクトリ、rawファイル、一般Webページを読み、回答やレビューに必要な文脈を取得するときに使う。'

  param :url, desc: '確認したいhttpまたはhttpsのURL'

  def execute(url:)
    ExternalContent.fetch(url)
  end
end
