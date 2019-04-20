# frozen_string_literal: true

class PracticePolicy < ApplicationPolicy
  attr_reader :user, :practice

  def initialize(user, practice)
    @user = user
    @practice = practice
  end

  def show?
    user.staff? || user.free? || user.card?
  end
end
