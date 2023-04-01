# frozen_string_literal: true

class Scheduler::Daily::SendMessageController < SchedulerController
  def show
    User.mark_message_as_sent_for_hibernated_student
    sent_student_followup_message
    head :ok
  end

  private

  def sent_student_followup_message
    User.students.find_each do |student|
      next unless student.followup_message_target?

      User.create_followup_comment(student)
    end
  end
end
