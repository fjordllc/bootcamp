# frozen_string_literal: true

class UserSubmittedProductsQuery
  def initialize(user)
    @user = user
  end

  def call
    @user
      .products
      .includes(:practice, :user, :comments, :checks, comments: :user)
      .not_wip
      .order(published_at: :desc)
  end
end
