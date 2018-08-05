class Product < ApplicationRecord
  include Commentable
  include Checkable

  belongs_to :practice
  belongs_to :user, touch: true
  after_create ProductCallbacks.new
  validates :user, presence: true, uniqueness: { scope: :practice, message: "既に提出物があります。" }
  validates :body, presence: true

  def self.checked?(practice)
    product = Product.find_by(practice_id: practice.id)
    return false if product.nil?
    product.checks.any?
  end
end
