# frozen_string_literal: true

class SkippedPracticeComponentPreview < ViewComponent::Preview
  # NOTE: このコンポーネントはform builderオブジェクトが必要なため、
  # Lookbook上での完全なプレビューは難しい場合があります。
  # 実際のフォームコンテキストで確認することを推奨します。

  def default
    user = OpenStruct.new(
      id: 1,
      login_name: 'yamada',
      course: OpenStruct.new(id: 1, title: 'Webエンジニアコース')
    )

    render(SkippedPracticeComponent.new(
      form: nil,
      user: user
    ))
  end
end
