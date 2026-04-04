# frozen_string_literal: true

class SkippedPracticeComponentPreview < ViewComponent::Preview
  # NOTE: SkippedPracticeComponentはUserCoursePractice（ActiveRecord依存）と
  # form builderオブジェクトが必要なため、Lookbook上での完全なプレビューは困難です。
  # 実際のフォームコンテキストで確認することを推奨します。
  #
  # このプレビューはプレースホルダーとして存在し、コンポーネントの存在を
  # カタログ上で示す目的で配置しています。

  def default
    render_with_template(template: 'skipped_practice_component_preview/default')
  end
end
