# frozen_string_literal: true

class PracticePolicy < ApplicationPolicy
  attr_reader :user, :practice

  def initialize(user, practice)
    super()
    @user = user
    @practice = practice
  end

  def show?
    UserStatus.new(user).staff? || UserBilling.new(user).card?
  end
end
