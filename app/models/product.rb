class Product < ApplicationRecord
  include Commentable
  include Checkable

  belongs_to :practice
  belongs_to :user, touch: true
  after_create ProductCallbacks.new
  validates :user, presence: true, uniqueness: { scope: :practice, message: "既に提出物があります。" }
  validates :body, presence: true

  scope :of_practice, -> (practice){ where(practice_id: practice.id) }

  def self.checked?(practice)
    products = Product.of_practice(practice)
    products.present? ? products.first.checks.any? : false
  end
end
