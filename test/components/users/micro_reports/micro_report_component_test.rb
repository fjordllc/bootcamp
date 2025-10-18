# frozen_string_literal: true

require 'test_helper'

class Users::MicroReports::MicroReportComponentTest < ViewComponent::TestCase
  def setup
    @user = users(:hatsuno)
    @other_user = users(:kimura)
  end

  def test_default
    micro_report = micro_reports(:hajime_first_micro_report)
    micro_report.comment_user ||= micro_report.user
    render_component(micro_report)

    assert_selector "img.micro-report_user-icon[title='#{micro_report.comment_user.icon_title}']"
    assert_selector '.micro-report__body', text: micro_report.content
    assert_selector 'time.micro-report__created-at', text: I18n.l(micro_report.created_at, format: :date_and_time)
    assert_text '👍1'
    assert_text '❤️1'
  end

  def test_posted_datetime_today
    micro_report = MicroReport.create!(user: @user, comment_user: @user, content: '今日の分報', created_at: Time.zone.now)
    render_component(micro_report)

    assert_includes page.text, "今日 #{I18n.l(Time.zone.now, format: :time_only)}"
  end

  def test_posted_datetime_yesterday
    micro_report = MicroReport.create!(user: @user, comment_user: @user, content: '昨日の分報', created_at: 1.day.ago)
    render_component(micro_report)

    assert_includes page.text, "昨日 #{I18n.l(1.day.ago, format: :time_only)}"
  end

  def test_posted_datetime_older_than_two_days
    micro_report = MicroReport.create!(user: @user, comment_user: @user, content: '2日前の分報', created_at: 2.days.ago)
    render_component(micro_report)

    assert_includes page.text, I18n.l(2.days.ago, format: :date_and_time)
  end

  def test_comment_user_is_not_post_owner
    micro_report = MicroReport.create!(user: @user, comment_user: @other_user, content: '他人のコメント')
    render_component(micro_report)

    assert_selector '.micro-report__body', text: '他人のコメント'
  end

  def test_edit_delete_buttons_visible_only_to_comment_user_or_admin
    micro_report = MicroReport.create!(user: @user, comment_user: @other_user, content: 'テスト')

    render_component(micro_report, current_user: @user)
    assert_no_selector '.micro-report__footer .micro-report-actions .is-edit'
    assert_no_selector '.micro-report__footer .micro-report-actions .is-delete'

    render_component(micro_report, current_user: @other_user)
    assert_selector '.micro-report__footer .micro-report-actions .is-edit'
    assert_selector '.micro-report__footer .micro-report-actions .is-delete'
  end

  private

  def render_component(micro_report, current_user: @user)
    component = Users::MicroReports::MicroReportComponent.new(
      user: micro_report.user,
      current_user:,
      micro_report:
    )
    render_inline(component)
  end
end
