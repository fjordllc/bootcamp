# frozen_string_literal: true

class Scheduler::Daily::AutoCloseQuestionsController < SchedulerController
  def show
    question_auto_closer = QuestionAutoCloser.new
    question_auto_closer.post_warning
    question_auto_closer.close_inactive_questions
    head :ok
  end
end
