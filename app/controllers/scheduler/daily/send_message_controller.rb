# frozen_string_literal: true

class Scheduler::Daily::SendMessageController < SchedulerController
  def show
    send_message_to_students_thirty_days_after_registration
    head :ok
  end

  private

  def send_message_to_students_thirty_days_after_registration
    @komagata = User.find_by(login_name: 'komagata')

    User.students.find_each do |student|
      next unless student.message_send_target?

      @komagata.comments.create(
        description: I18n.t('send_message.description'),
        commentable_id: Talk.find_by(user_id: student.id).id,
        commentable_type: 'Talk'
      )
      student.update(sent_message_after_thirty_days: true)
    end
  end
end
