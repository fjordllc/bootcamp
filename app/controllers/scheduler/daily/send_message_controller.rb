# frozen_string_literal: true

class Scheduler::Daily::SendMessageController < SchedulerController
  def show
    User.mark_message_as_sent_for_hibernated_student
    sent_student_followup_message
    head :ok
  end

  private

  def sent_student_followup_message
    @komagata = User.find_by(login_name: 'komagata')

    User.students.find_each do |student|
      next unless student.followup_message_target?

      @komagata.comments.create(
        description: I18n.t('send_message.description'),
        commentable_id: Talk.find_by(user_id: student.id).id,
        commentable_type: 'Talk'
      )
      student.assign_attributes(sent_student_followup_message: true)
      student.save(context: :followup_message)
    end
  end
end
