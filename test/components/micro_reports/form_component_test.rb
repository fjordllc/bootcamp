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

  test 'returns correct form_action_path for Users::MicroReportsController' do
    render_inline(
      MicroReports::FormComponent.new(
        user: @user,
        controller_name: 'Users::MicroReportsController'
      )
    )

    assert_selector "form[action='/users/#{@user.id}/micro_reports#latest-micro-report']"
  end

  test 'returns correct form_action_path for CurrentUser::MicroReportsController' do
    render_inline(
      MicroReports::FormComponent.new(
        user: @user,
        controller_name: 'CurrentUser::MicroReportsController'
      )
    )

    assert_selector "form[action='/current_user/micro_reports#latest-micro-report']"
  end

  test 'raises error for unsupported controller' do
    error = assert_raises(RuntimeError) do
      render_inline(MicroReports::FormComponent.new(
                      user: @user,
                      controller_name: 'UnknownController'
                    ))
    end

    assert_equal 'Unsupported controller: UnknownController', error.message
  end

  test 'raises error when controller_name is nil' do
    error = assert_raises(RuntimeError) do
      render_inline(MicroReports::FormComponent.new(
                      user: @user,
                      controller_name: nil
                    ))
    end

    assert_match(/controller/, error.message)
  end
end
