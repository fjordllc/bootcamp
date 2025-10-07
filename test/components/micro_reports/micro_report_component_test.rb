# frozen_string_literal: true

require 'test_helper'

class MicroReports::MicroReportComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  def setup
    @user = users(:hatsuno)
    @micro_report = micro_reports(:hajime_first_micro_report)
  end

  def test_default
    render_component(@micro_report)

    assert_selector "img.micro-report_user-icon[title='#{@micro_report.user.icon_title}']"
    assert_selector '.micro-report__body', text: @micro_report.content
    assert_selector 'time.micro-report__created-at', text: I18n.l(@micro_report.created_at, format: :date_and_time)
    assert_text '👍1'
    assert_text '❤️1'
  end

  def test_posted_datetime_today
    now = Time.zone.now
    micro_report = @user.micro_reports.create(content: '今日の分報', created_at: now)
    render_component(micro_report)

    assert_includes page.text, "今日 #{I18n.l(now, format: :time_only)}"
  end

  def test_posted_datetime_yesterday
    yesterday = 1.day.ago
    micro_report = @user.micro_reports.create(content: '昨日の分報', created_at: yesterday)
    render_component(micro_report)

    assert_includes page.text, "昨日 #{I18n.l(yesterday, format: :time_only)}"
  end

  def test_posted_datetime_older_than_two_days
    two_days_ago = 2.days.ago
    micro_report = @user.micro_reports.create(content: '2日前の分報', created_at: two_days_ago)
    render_component(micro_report)

    assert_includes page.text, I18n.l(two_days_ago, format: :date_and_time)
  end

  def test_delete_path_returns_correct_path_for_users_controller
    user = users(:hajime)
    render_inline(
      MicroReports::MicroReportComponent.new(
        user:,
        current_user: user,
        micro_report: @micro_report,
        controller_name: 'Users::MicroReportsController'
      )
    )

    assert_selector "a.micro-report-actions__action.is-delete[href='/users/#{user.id}/micro_reports/#{@micro_report.id}']"
  end

  def test_delete_path_returns_correct_path_for_current_user_controller
    user = users(:hajime)
    render_inline(
      MicroReports::MicroReportComponent.new(
        user:,
        current_user: user,
        micro_report: @micro_report,
        controller_name: 'CurrentUser::MicroReportsController'
      )
    )

    assert_selector "a.micro-report-actions__action.is-delete[href='/current_user/micro_reports/#{@micro_report.id}']"
  end

  def test_delete_path_raises_error_when_unsupported_controller
    user = users(:hajime)
    error = assert_raises(RuntimeError) do
      render_inline(
        MicroReports::MicroReportComponent.new(
          user:,
          current_user: user,
          micro_report: @micro_report,
          controller_name: 'UnknownController'
        )
      )
    end

    assert_equal 'Unsupported controller: UnknownController', error.message
  end

  def test_delete_path_raises_error_when_controller_name_is_nil
    user = users(:hajime)
    error = assert_raises(RuntimeError) do
      render_inline(
        MicroReports::MicroReportComponent.new(
          user:,
          current_user: user,
          micro_report: @micro_report,
          controller_name: nil
        )
      )
    end

    assert_match(/controller/, error.message)
  end

  private

  def render_component(micro_report)
    component = MicroReports::MicroReportComponent.new(
      user: micro_report.user,
      current_user: @user,
      controller_name: 'Users::MicroReportsController',
      micro_report:
    )
    render_inline(component)
  end
end
