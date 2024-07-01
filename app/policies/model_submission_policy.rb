# frozen_string_literal: true

class ModelSubmissionPolicy < ApplicationPolicy
  attr_reader :user, :model_submission

  def initialize(user, model_submission)
    super()
    @user = user
    @model_submission = model_submission
  end

  def show?
    user.admin? ||
      user.mentor? ||
      user.adviser? ||
      user.graduated_on? ||
      model_submission.practice.completed?(user) ||
      model_submission.practice.product(user)&.completed?(user)
  end
end
