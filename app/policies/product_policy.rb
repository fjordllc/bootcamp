# frozen_string_literal: true

class ProductPolicy < ApplicationPolicy
  attr_reader :user, :product

  def initialize(user, product)
    @user = user
    @product = product
  end

  def show?
    user.admin? ||
      user.mentor? ||
      user.adviser? ||
      user == product.user ||
      product.practice.completed?(user) ||
      product.completed?(user)
  end
end
