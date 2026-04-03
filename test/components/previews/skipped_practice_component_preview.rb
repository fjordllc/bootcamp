# frozen_string_literal: true

class SkippedPracticeComponentPreview < ViewComponent::Preview
  # NOTE: SkippedPracticeComponentはUserCoursePractice（ActiveRecord依存）と
  # form builderオブジェクトが必要なため、Lookbook上での完全なプレビューは困難です。
  # 実際のフォームコンテキストで確認することを推奨します。
  #
  # このプレビューはプレースホルダーとして存在し、コンポーネントの存在を
  # カタログ上で示す目的で配置しています。

  def default
    render(inline: <<~HTML)
      <div class="a-card" style="padding: 1rem;">
        <p><strong>SkippedPracticeComponent</strong></p>
        <p>このコンポーネントはActiveRecordとform builderに依存するため、<br>
        Lookbook上ではプレビューできません。</p>
        <p>実際のフォーム画面で確認してください。</p>
      </div>
    HTML
  end
end
