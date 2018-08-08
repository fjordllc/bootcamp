class Product < ApplicationRecord
  include Commentable
  include Checkable

  belongs_to :practice
  belongs_to :user, touch: true
  after_create ProductCallbacks.new
  validates :user, presence: true, uniqueness: { scope: :practice, message: "既に提出物があります。" }
  validates :body, presence: true

  def checked?
    checks.present?
  end
end
