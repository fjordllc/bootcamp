# frozen_string_literal: true

class Scheduler::Daily::SendMessageController < SchedulerController
  def show
    mark_message_as_sent_for_hibernated_student
    sent_student_followup_message
    head :ok
  end

  private

  # FIXME: 一次対応として一回でも休会している受講生にはメッセージ送信済みとする
  #        別Issueで入会n日目、休会開けn日目目の受講生にメッセージを送信する方針へ改修してほしい
  #        改修後、このメソッドは不要になると思われるので削除すること
  def mark_message_as_sent_for_hibernated_student
    User.hibernated.update_all(sent_student_followup_message: true, updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
  end

  def sent_student_followup_message
    User.students.find_each do |student|
      next unless student.followup_message_target?

      CreateFollowupComment.call(student: student)
    end
  end
end
