# frozen_string_literal: true

require 'test_helper'

class MicroReports::FormComponentTest < ViewComponent::TestCase
  def setup
    @user = users(:hatsuno)
  end

  def test_default
    render_inline(MicroReports::FormComponent.new(user: @user, controller_name: 'Users::MicroReportsController'))

    assert_selector '.micro-report-form-tabs__item-link.is-active', text: '分報'
    assert_selector '.micro-report-form-tabs__item-link', text: 'プレビュー'
    assert_selector 'textarea#js-micro-report-textarea'
    assert_selector "input[type=submit][value='投稿']"
  end

  def test_form_action_path_returns_correct_path_for_users_controller
    render_inline(
      MicroReports::FormComponent.new(
        user: @user,
        controller_name: 'Users::MicroReportsController'
      )
    )

    assert_selector "form[action='/users/#{@user.id}/micro_reports#latest-micro-report']"
  end

  def test_form_action_path_returns_correct_path_for_current_user_controller
    render_inline(
      MicroReports::FormComponent.new(
        user: @user,
        controller_name: 'CurrentUser::MicroReportsController'
      )
    )

    assert_selector "form[action='/current_user/micro_reports#latest-micro-report']"
  end

  def test_form_action_path_raises_error_when_unsupported_controller
    error = assert_raises(RuntimeError) do
      render_inline(MicroReports::FormComponent.new(
                      user: @user,
                      controller_name: 'UnknownController'
                    ))
    end

    assert_equal 'Unsupported controller: UnknownController', error.message
  end

  def test_form_action_path_raises_error_when_controller_name_is_nil
    error = assert_raises(RuntimeError) do
      render_inline(MicroReports::FormComponent.new(
                      user: @user,
                      controller_name: nil
                    ))
    end

    assert_match(/controller/, error.message)
  end
end
