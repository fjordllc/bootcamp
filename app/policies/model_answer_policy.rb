# frozen_string_literal: true

class ModelAnswerPolicy < ApplicationPolicy
  attr_reader :user, :model_answer

  def initialize(user, model_answer)
    super()
    @user = user
    @model_answer = model_answer
  end

  def show?
    user.admin? ||
      user.mentor? ||
      user.adviser? ||
      user.graduated_on? ||
      model_answer.practice.completed?(user) ||
      model_answer.practice.product(user)&.completed?(user)
  end
end
