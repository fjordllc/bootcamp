# frozen_string_literal: true

require 'test_helper'

class Users::MicroReports::MicroReportComponentTest < ViewComponent::TestCase
  def setup
    @user = users(:hatsuno)
  end

  def test_posted_datetime_today
    micro_report = micro_reports(:hajime_third_micro_report)
    render_component(micro_report)

    assert_includes page.text, "今日 #{Time.zone.now.strftime('%H:%M')}"
  end

  def test_posted_datetime_yesterday
    micro_report = micro_reports(:hajime_second_micro_report)
    render_component(micro_report)

    assert_includes page.text, "昨日 #{1.day.ago.strftime('%H:%M')}"
  end

  def test_posted_datetime_older_than_two_days
    micro_report = micro_reports(:hajime_first_micro_report)
    render_component(micro_report)

    assert_includes page.text, 2.days.ago.strftime('%Y/%m/%d %H:%M')
  end

  private

  def render_component(micro_report)
    component = Users::MicroReports::MicroReportComponent.new(
      user: @user,
      current_user: @user,
      micro_report:
    )
    render_inline(component)
  end
end
