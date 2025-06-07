# frozen_string_literal: true

module Scheduler
  module Daily
    class AutoCloseQuestionsController < ApplicationController
      def show
        QuestionAutoCloser.post_warning
        QuestionAutoCloser.close_and_select_best_answer
        head :ok
      end
    end
  end
end
