# frozen_string_literal: true

class SubmissionAnswerPolicy < ApplicationPolicy
  attr_reader :user, :submission_answer

  def initialize(user, submission_answer)
    super()
    @user = user
    @submission_answer = submission_answer
  end

  def show?
    user.admin? ||
      user.mentor? ||
      user.adviser? ||
      user.graduated_on? ||
      submission_answer.practice.product(user)&.checked? ||
      submission_answer.practice.completed?(user)
  end
end
