# frozen_string_literal: true

class Scheduler::Daily::NotifyCertainPeriodPassedAfterLastAnswerController < ApplicationController
  def show
    Question.notify_certain_period_passed_after_last_answer
    head :ok
  end
end
