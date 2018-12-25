# frozen_string_literal: true

class Product < ApplicationRecord
  include Commentable
  include Checkable
  include Footprintable

  belongs_to :practice
  belongs_to :user, touch: true

  after_create ProductCallbacks.new
  after_update ProductCallbacks.new

  validates :user, presence: true, uniqueness: { scope: :practice, message: "既に提出物があります。" }
  validates :body, presence: true

  scope :ids_of_common_checked_with,
    -> (user) { where(practice: user.practices_with_checked_product).checked.pluck(:id) }

  scope :unchecked, -> { where.not(id: Check.where(checkable_type: "Product").pluck(:checkable_id)) }
end
