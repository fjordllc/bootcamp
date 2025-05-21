# frozen_string_literal: true

module Scheduler
  module Daily
    class AutoCloseQuestionsController < ApplicationController
      def show
        QuestionAutoClose.post_auto_close_warning
        QuestionAutoClose.auto_close_and_select_best_answer
        head :ok
      end
    end
  end
end
