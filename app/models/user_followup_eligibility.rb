# frozen_string_literal: true

# ユーザーがフォローアップメッセージの送信対象かどうかを判定する責務を持つ。
# 在籍ステータスそのものとは異なり、フォローアップの運用ルールの変更で条件が変わりうる。
class UserFollowupEligibility
  def initialize(user)
    @user = user
  end

  def eligible?
    @user.current_student? && !@user.hibernated? && after_twenty_nine_days_registration? && !@user.sent_student_followup_message
  end

  private

  def after_twenty_nine_days_registration?
    twenty_nine_days = Time.current.ago(29.days).to_date
    @user.created_at.to_date.before? twenty_nine_days
  end
end
