# frozen_string_literal: true

class UsersMicroReportsMicroReportComponentPreview < ViewComponent::Preview
  include PreviewHelper

  def default
    user = build_mock_user
    current_user = build_mock_user(id: 2, login_name: 'viewer', name: 'viewer', icon_title: 'viewer')
    micro_report = mock_micro_report(user: user, content: '今日はRubyの基礎を学習しました。配列操作が面白かった。')

    render(Users::MicroReports::MicroReportComponent.new(
             user: user, current_user: current_user, micro_report: micro_report
           ))
  end

  def long_content
    user = build_mock_user
    current_user = build_mock_user(id: 2, login_name: 'viewer', name: 'viewer', icon_title: 'viewer')
    micro_report = mock_micro_report(user: user, content: 'とても長いマイクロレポートです。' * 10)

    render(Users::MicroReports::MicroReportComponent.new(
             user: user, current_user: current_user, micro_report: micro_report
           ))
  end

  private

  def mock_micro_report(user:, content:)
    report = OpenStruct.new(id: rand(1000), content: content, created_at: rand(1..5).hours.ago, comment_user: user)
    report.define_singleton_method(:reaction_count_by) { |_kind| 0 }
    report.define_singleton_method(:reaction_login_names_by) { |_kind| [] }
    report.define_singleton_method(:find_reaction_id_by) { |_kind, _login| nil }
    report.define_singleton_method(:to_global_id) { "gid://bootcamp/MicroReport/#{id}" }
    report
  end
end
