# frozen_string_literal: true

class Product < ApplicationRecord
  PRODUCT_DEADLINE = 4

  include Commentable
  include Checkable
  include Footprintable
  include Watchable
  include Reactionable
  include WithAvatar
  include Mentioner
  include Searchable
  include Bookmarkable
  include Taskable
  include ProductStatus

  delegate :replied_status_changed?, :update_last_commented_at, :update_commented_at,
           :delete_last_commented_at, :delete_commented_at, to: :commented_at_tracking

  belongs_to :practice
  belongs_to :user, touch: true
  belongs_to :checker, class_name: 'User', optional: true
  alias sender user

  after_create ProductCallbacks.new
  after_update ProductCallbacks.new
  after_save_commit ProductCallbacks.new
  after_destroy ProductCallbacks.new

  columns_for_keyword_search :body

  validates :user, presence: true, uniqueness: { scope: :practice, message: '既に提出物があります。' }
  validates :body, presence: true

  paginates_per 50

  mentionable_as :body

  def self.ransackable_attributes(_auth_object = nil)
    %w[body wip published_at commented_at created_at updated_at user_id practice_id checker_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user practice checker comments reactions checks bookmarks]
  end

  def self.self_assigned_no_replied_products(user_id)
    ProductSelfAssignedNoRepliedQuery.new(user_id:).call
  end

  def self.require_assignment_products
    Product.all
           .unassigned
           .unchecked
           .not_wip
           .list
           .ascending_by_date_of_publishing_and_id
  end

  def self.group_by_elapsed_days(products)
    reply_deadline_days = PRODUCT_DEADLINE + 2
    products.group_by do |product|
      product.elapsed_days >= reply_deadline_days ? reply_deadline_days : product.elapsed_days
    end
  end

  def completed?(user)
    checks.where(user:).present?
  end

  # nilの場合あり
  def learning
    Learning.find_by(
      user_id: user.id,
      practice_id: practice.id
    )
  end

  def text_for_embedding
    truncate_for_embedding(body)
  end

  def category(course)
    Category.category(practice:, course:)
  end

  def elapsed_days
    t = published_at || created_at
    ((Time.current - t) / 1.day).to_i
  end

  def notification_type
    updated_after_submission? ? :product_update : :submitted
  end

  def updated_after_submission?
    return false if saved_change_to_attribute?('published_at', from: nil)

    created_at != updated_at
  end

  def search_title
    practice.title
  end

  def commented_at_tracking
    ProductCommentedAtTracking.new(self)
  end

  def assignment
    ProductAssignment.new(self)
  end
end
