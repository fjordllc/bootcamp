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

  def test_skipped_practices_count
    assert_text('学習の準備(0)')
    assert_text('UNIX(1/9)')
  end
end
