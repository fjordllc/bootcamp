# frozen_string_literal: true

require 'test_helper'

class SkippedPracticeComponentTest < ViewComponent::TestCase
  # ActionView::Base.emptyを使ったFormBuilderはViewComponentのrender_inlineと
  # 互換性がなく、collection_check_boxesのブロックで無限ループが発生する。
  # そのため、render_inlineを使わずにコンポーネントのロジックのみをテストする。
  def test_skipped_practices_count
    user = users(:kensyu)
    user_course_practice = UserCoursePractice.new(user)
    categories = user_course_practice.categories_for_skip_practice

    # カテゴリが正しく取得できることを確認
    assert categories.present?

    # 各カテゴリにnameとpracticesがあることを確認
    categories.each do |category|
      assert category.name.present?
      assert_respond_to category, :practices
      assert_respond_to category, :practice_ids
    end

    # skipped_practices_countメソッドのテスト
    form_builder = ActionView::Helpers::FormBuilder.new(:user, user, ActionView::Base.empty, {})
    component = SkippedPracticeComponent.new(form: form_builder, user:)
    categories.each do |category|
      count = component.skipped_practices_count(category)
      assert_match %r{\(\d+/?\d*\)}, count
    end
  end
end
