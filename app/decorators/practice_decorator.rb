# frozen_string_literal: true

module PracticeDecorator
  def submission_answer_button?(viewer)
    viewer.mentor? && submission && !submission_answer
  end
end
