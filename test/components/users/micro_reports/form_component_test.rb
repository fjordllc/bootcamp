# frozen_string_literal: true

require 'test_helper'

class Users::MicroReports::FormComponentTest < ViewComponent::TestCase
  def setup
    @user = users(:hatsuno)
  end

  def test_default
    render_inline(Users::MicroReports::FormComponent.new(user: @user))

    assert_selector '.micro-report-form-tabs__item-link.is-active', text: '分報'
    assert_selector '.micro-report-form-tabs__item-link', text: 'プレビュー'
    assert_selector 'textarea#js-micro-report-textarea'
    assert_selector "input[type=submit][value='投稿']"
  end
end
