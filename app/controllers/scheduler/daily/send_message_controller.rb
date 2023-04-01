# frozen_string_literal: true

class Scheduler::Daily::SendMessageController < SchedulerController
  def show
    User.mark_message_as_sent_for_hibernated_student
    sent_student_followup_message(from_user)
    head :ok
  end

  private

  def from_user
    User.find_by(login_name: 'komagata')
  end

  def sent_student_followup_message(from_user)
    User.students.find_each do |student|
      next unless student.followup_message_target?

      User.create_followup_comment(from_user, student)
    end
  end
end
