# frozen_string_literal: true

class Product < ApplicationRecord
  include Commentable
  include Checkable
  include Footprintable
  include Watchable
  include Reactionable
  include WithAvatar

  belongs_to :practice
  belongs_to :user, touch: true
  has_many :watches, as: :watchable, dependent: :destroy

  after_create ProductCallbacks.new
  after_destroy ProductCallbacks.new

  validates :user, presence: true, uniqueness: { scope: :practice, message: "既に提出物があります。" }
  validates :body, presence: true

  paginates_per 50

  scope :ids_of_common_checked_with,
    -> (user) { where(practice: user.practices_with_checked_product).checked.pluck(:id) }

  scope :unchecked, -> { where.not(id: Check.where(checkable_type: "Product").pluck(:checkable_id)) }

  scope :wip, -> { where(wip: true) }
  scope :not_wip, -> { where(wip: false) }
  scope :list, -> {
    with_avatar
      .preload([:practice, :comments, { checks: { user: { avatar_attachment: :blob } } }])
      .order(created_at: :desc)
  }

  def self.not_responded_products
    sql = <<-SQL
WITH last_comments AS (
  SELECT *
  FROM comments AS parent
  WHERE commentable_type = 'Product' AND id = (
    SELECT id
    FROM comments AS child
    WHERE parent.commentable_id = child.commentable_id
      AND commentable_type = 'Product'
    ORDER BY created_at DESC LIMIT 1
  )
),
unchecked_products AS (
  SELECT products.*
  FROM products
  LEFT JOIN checks ON products.id = checks.checkable_id AND checks.checkable_type = 'Product'
  WHERE checks.id IS NULL AND wip = false
)
SELECT unchecked_products.id
FROM unchecked_products
LEFT JOIN last_comments ON unchecked_products.id = last_comments.commentable_id
WHERE last_comments.id IS NULL
OR unchecked_products.user_id = last_comments.user_id
ORDER BY unchecked_products.created_at DESC
    SQL
    product_ids = Product.find_by_sql(sql).map(&:id)
    Product.where(id: product_ids).order(created_at: :desc)
  end

  def completed?(user)
    checks.where(user: user).present?
  end

  def product_checked
    learning = Learning.find_by(user_id: self.user.id, practice_id: self.practice.id)
    if learning
      learning.product_confirmed
    else
      Learning.create(user_id: self.user.id, practice_id: self.practice.id, status: "complete")
    end
  end
end
