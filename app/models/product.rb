class Product < ApplicationRecord
  include Commentable
  include Checkable

  belongs_to :practice
  belongs_to :user, touch: true
  after_create ProductCallbacks.new
  validates :user, presence: true, uniqueness: { scope: :practice, message: "既に提出物があります。" }
  validates :body, presence: true

  # def user_passed?
  #   product = Product.find_by(user_id: current_user.id, practice_id: @practice.id)
  #   if product
  #     product.checks.any?
  #   end
  # end
end
