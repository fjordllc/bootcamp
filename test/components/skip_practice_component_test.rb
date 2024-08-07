# frozen_string_literal: true

require 'test_helper'

class SkippedPracticeComponentTest < ViewComponent::TestCase
  include ActionView::Helpers::FormHelper
  include ActionView::Context

  setup do
    @user = users(:kensyu).extend(UserDecorator)
    @form_builder = ActionView::Helpers::FormBuilder.new(:user, @user, ActionView::Base.empty, {})
    @component = SkippedPracticeComponent.new(form: @form_builder, user: @user)
    render_inline(@component)
  end

  # user categories に所属するプラクティスが重複がなくなっていること
  def test_user_categories
    assert_selector 'label', text: '複数カテゴリに所属するプラクティス1', count: 1
    assert_selector 'label', text: '複数カテゴリに所属するプラクティス2', count: 1
  end
end
