# frozen_string_literal: true

require 'test_helper'

class Users::MicroReports::MicroReportComponentTest < ViewComponent::TestCase
  def setup
    @user = users(:hatsuno)
  end

  def test_render_component
    micro_report = micro_reports(:hajime_first_micro_report)
    render_component(micro_report)

    assert_selector "img.page-content-header__user-icon[title='#{micro_report.user.icon_title}']"
    assert_selector '.thread-comment__description', text: micro_report.content
    assert_selector 'time.thread-comment__created-at', text: micro_report.created_at.strftime('%Y/%m/%d %H:%M')
    assert_text '👍1'
    assert_text '❤️1'
  end

  def test_posted_datetime_today
    micro_report = @user.micro_reports.create(content: '今日の分報', created_at: Time.zone.now)
    render_component(micro_report)

    assert_includes page.text, "今日 #{Time.zone.now.strftime('%H:%M')}"
  end

  def test_posted_datetime_yesterday
    micro_report = @user.micro_reports.create(content: '昨日の分報', created_at: 1.day.ago)
    render_component(micro_report)

    assert_includes page.text, "昨日 #{1.day.ago.strftime('%H:%M')}"
  end

  def test_posted_datetime_older_than_two_days
    micro_report = @user.micro_reports.create(content: '2日前の分報', created_at: 2.days.ago)
    render_component(micro_report)

    assert_includes page.text, 2.days.ago.strftime('%Y/%m/%d %H:%M')
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
