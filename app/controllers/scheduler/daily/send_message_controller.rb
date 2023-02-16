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
    User.find_each do |user|
      if user.hibernated?
        user.assign_attributes(sent_student_followup_message: true)
        user.save(context: :followup_message)
      end
    end
  end

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
