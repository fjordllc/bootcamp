# frozen_string_literal: true

class UserInfoTool < RubyLLM::Tool
  description 'メンションしてきたユーザーのプロフィールやカリキュラムの進捗状況を取得する。' \
              'ユーザーに合わせた回答をするときに使う。'

  param :login_name, desc: 'ユーザーのログイン名'

  def execute(login_name:)
    user = User.find_by(login_name: login_name)
    return "ユーザー「#{login_name}」が見つかりませんでした。" if user.nil?

    build_user_info(user)
  end

  private

  def build_user_info(user)
    sections = [
      profile_section(user),
      progress_section(user),
      activity_section(user)
    ].compact

    sections.join("\n\n")
  end

  def profile_section(user)
    lines = ['## プロフィール']
    lines << "- 名前: #{user.name}"
    lines << "- ログイン名: #{user.login_name}"
    lines << "- コース: #{user.course&.title}" if user.course.present?
    lines << "- 自己紹介: #{user.description.truncate(200)}" if user.description.present?
    lines << "- 職業: #{user.profile_job}" if user.profile_job.present?
    lines << "- 入会日: #{user.created_at.strftime('%Y年%m月%d日')}"
    lines << "- 卒業日: #{user.graduated_on.strftime('%Y年%m月%d日')}" if user.graduated_on.present?
    lines << "- ロール: #{user_role_label(user)}"
    lines.join("\n")
  end

  def progress_section(user)
    return nil if user.admin? || user.mentor? || user.adviser?

    ucp = UserCoursePractice.new(user)
    completed = ucp.completed_practices.size
    required = ucp.required_practices.size
    percentage = required.positive? ? ucp.completed_percentage.round(1) : 0

    active = user.active_practices.limit(5).pluck(:title)

    lines = ['## カリキュラム進捗']
    lines << "- 完了プラクティス数: #{completed}"
    lines << "- 必須プラクティス数: #{required}"
    lines << "- 進捗率: #{percentage}%"
    lines << "- 現在取り組み中: #{active.join(', ')}" if active.present?
    lines.join("\n")
  end

  def activity_section(user)
    lines = ['## 最近の活動']

    last_report = user.reports.order(created_at: :desc).first
    lines << "- 最後の日報: #{last_report.created_at.strftime('%Y年%m月%d日')}「#{last_report.title.truncate(50)}」" if last_report

    question_count = user.questions.count
    lines << "- Q&A投稿数: #{question_count}" if question_count.positive?

    product_count = user.products.count
    lines << "- 提出物数: #{product_count}" if product_count.positive?

    lines.size > 1 ? lines.join("\n") : nil
  end

  def user_role_label(user)
    return '管理者' if user.admin?
    return 'メンター' if user.mentor?
    return 'アドバイザー' if user.adviser?
    return '研修生' if user.trainee?
    return '卒業生' if user.graduated?

    '受講生'
  end
end
