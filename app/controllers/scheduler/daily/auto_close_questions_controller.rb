# frozen_string_literal: true

class Scheduler::Daily::AutoCloseQuestionsController < SchedulerController
  def show
    QuestionAutoCloser.post_warning
    QuestionAutoCloser.close_and_select_best_answer
    head :ok
  end
end
