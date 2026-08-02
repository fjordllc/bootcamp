# frozen_string_literal: true

module Comebackable
  extend ActiveSupport::Concern

  def last_hibernation
    return nil if hibernations.empty?

    hibernations.order(:created_at).last
  end

  def hibernation_elapsed_days
    (Time.zone.today - hibernated_at.to_date).to_i
  end

  def create_comebacked_comment
    User.find_by(login_name: 'pjord').comments.create(
      description: I18n.t('talk.comeback'),
      commentable_id: Talk.find_by(user_id: id).id,
      commentable_type: 'Talk'
    )
  end

  def scheduled_retire_at
    hibernated_at + User::HIBERNATION_LIMIT if hibernated_at?
  end

  def mark_mail_as_sent_before_auto_retire
    self.sent_student_before_auto_retire_mail = true
    save(validate: false)
  end

  def clear_github_data
    update(
      github_id: nil,
      github_account: nil,
      github_collaborator: false
    )
  end

  class_methods do
    # FIXME: 一次対応として一回でも休会している受講生にはメッセージ送信済みとする
    #        別Issueで入会n日目、休会開けn日目目の受講生にメッセージを送信する方針へ改修してほしい
    #        改修後、このメソッドは不要になると思われるので削除すること
    def mark_message_as_sent_for_hibernated_student
      User.hibernated.update_all(sent_student_followup_message: true, updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    end

    def create_followup_comment(student)
      User.find_by(login_name: 'pjord').comments.create(
        description: I18n.t('talk.followup'),
        commentable_id: Talk.find_by(user_id: student.id).id,
        commentable_type: 'Talk'
      )
      student.sent_student_followup_message = true
      student.save(validate: false)
    end
  end
end
