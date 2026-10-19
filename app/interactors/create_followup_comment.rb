# frozen_string_literal: true

class CreateFollowupComment
  include Interactor

  def call
    User.find_by(login_name: 'pjord').comments.create(
      description: I18n.t('talk.followup'),
      commentable_id: Talk.find_by(user_id: context.student.id).id,
      commentable_type: 'Talk'
    )
    context.student.sent_student_followup_message = true
    context.student.save(validate: false)
  end
end
