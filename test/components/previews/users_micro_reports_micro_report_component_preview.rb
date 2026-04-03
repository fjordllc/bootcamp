# frozen_string_literal: true

class UsersMicroReportsMicroReportComponentPreview < ViewComponent::Preview
  def default
    user = mock_user
    current_user = mock_user(name: 'current_user', login_name: 'current')
    micro_report = mock_micro_report(user: user, content: '今日はRubyの基礎を学習しました。メソッドの定義について理解が深まりました。')

    render(Users::MicroReports::MicroReportComponent.new(
             user: user,
             current_user: current_user,
             micro_report: micro_report
           ))
  end

  def owner_post
    user = mock_user
    micro_report = mock_micro_report(user: user, content: '自分の投稿です。プログラミングが楽しいです！')

    render(Users::MicroReports::MicroReportComponent.new(
             user: user,
             current_user: user,
             micro_report: micro_report
           ))
  end

  def long_content
    user = mock_user
    current_user = mock_user(name: 'current_user', login_name: 'current')
    long_text = 'とても長いマイクロレポートです。' * 10
    micro_report = mock_micro_report(user: user, content: long_text)

    render(Users::MicroReports::MicroReportComponent.new(
             user: user,
             current_user: current_user,
             micro_report: micro_report
           ))
  end

  private

  def mock_user(name: 'yamada', login_name: 'yamada')
    user = OpenStruct.new(
      id: rand(1000),
      login_name: login_name,
      name: name,
      primary_role: 'student',
      avatar_url: 'https://via.placeholder.com/40',
      icon_title: name,
      user_icon_frame_class: 'a-user-role is-student'
    )
    user.define_singleton_method(:icon_classes) { |image_class| ['a-user-icon', image_class].compact.join(' ') }
    user.define_singleton_method(:to_param) { login_name }
    user.define_singleton_method(:persisted?) { true }
    user.define_singleton_method(:model_name) { OpenStruct.new(route_key: 'users', singular_route_key: 'user') }
    user
  end

  def mock_micro_report(user:, content:)
    OpenStruct.new(
      id: rand(1000),
      content: content,
      created_at: rand(1..5).hours.ago,
      comment_user: user
    )
  end
end
