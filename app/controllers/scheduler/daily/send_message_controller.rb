# frozen_string_literal: true

class Scheduler::Daily::SendMessageController < SchedulerController
  def show
    UserHibernation.mark_message_as_sent_for_hibernated_student
    sent_student_followup_message
    head :ok
  end

  private

  def sent_student_followup_message
    User.students.find_each do |student|
      next unless student.status.followup_message_target?

      CreateFollowupComment.call(student: student)
    end
  end
end
