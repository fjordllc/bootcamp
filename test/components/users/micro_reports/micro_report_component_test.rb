# frozen_string_literal: true

require 'test_helper'

class Users::MicroReports::MicroReportComponentTest < ViewComponent::TestCase
  def setup
    @user = users(:hatsuno)
  end

  def test_default
    micro_report = micro_reports(:hajime_first_micro_report)
    render_component(micro_report)

    assert_selector "img.micro-report_user-icon[title='#{micro_report.user.icon_title}']"
    assert_selector '.micro-report__body', text: micro_report.content
    assert_selector 'time.micro-report__created-at', text: I18n.l(micro_report.created_at, format: :date_and_time)
    assert_text '👍1'
    assert_text '❤️1'
  end

  def test_posted_datetime_today
    micro_report = @user.micro_reports.create(content: '今日の分報', created_at: Time.zone.now)
    render_component(micro_report)

    assert_includes page.text, "今日 #{I18n.l(Time.zone.now, format: :time_only)}"
  end

  def test_posted_datetime_yesterday
    micro_report = @user.micro_reports.create(content: '昨日の分報', created_at: 1.day.ago)
    render_component(micro_report)

    assert_includes page.text, "昨日 #{I18n.l(1.day.ago, format: :time_only)}"
  end

  def test_posted_datetime_older_than_two_days
    micro_report = @user.micro_reports.create(content: '2日前の分報', created_at: 2.days.ago)
    render_component(micro_report)

    assert_includes page.text, I18n.l(2.days.ago, format: :date_and_time)
  end

  private

  def render_component(micro_report)
    component = Users::MicroReports::MicroReportComponent.new(
      user: micro_report.user,
      current_user: @user,
      micro_report:
    )
    render_inline(component)
  end
end
