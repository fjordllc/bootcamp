# frozen_string_literal: true

class ProductPolicy < ApplicationPolicy
  def show?
    @user.admin? || @user.mentor? || @user.adviser? ||
      product.checks.where(user: @user).present?
  end
end
