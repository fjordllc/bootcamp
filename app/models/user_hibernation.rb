# frozen_string_literal: true

class UserHibernation
  def initialize(user)
    @user = user
  end

  def last_hibernation
    return nil if @user.hibernations.empty?

    @user.hibernations.order(:created_at).last
  end

  def hibernation_elapsed_days
    (Time.zone.today - @user.hibernated_at.to_date).to_i
  end

  def scheduled_retire_at
    @user.hibernated_at + User::HIBERNATION_LIMIT if @user.hibernated_at?
  end

  def mark_mail_as_sent_before_auto_retire
    @user.sent_student_before_auto_retire_mail = true
    @user.save(validate: false)
  end

  def create_comebacked_comment
    User.find_by(login_name: 'pjord').comments.create(
      description: I18n.t('talk.comeback'),
      commentable_id: Talk.find_by(user_id: @user.id).id,
      commentable_type: 'Talk'
    )
  end

  # FIXME: 一次対応として一回でも休会している受講生にはメッセージ送信済みとする
  #        別Issueで入会n日目、休会開けn日目目の受講生にメッセージを送信する方針へ改修してほしい
  #        改修後、このメソッドは不要になると思われるので削除すること
  def self.mark_message_as_sent_for_hibernated_student
    User.hibernated.update_all(sent_student_followup_message: true, updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
  end
end
