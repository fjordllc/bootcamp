# frozen_string_literal: true

class Product < ApplicationRecord
  include Commentable
  include Checkable
  include Footprintable
  include Watchable
  include Reactionable
  include WithAvatar
  include Mentioner
  include Searchable

  belongs_to :practice
  belongs_to :user, touch: true
  alias sender user

  after_create ProductCallbacks.new
  after_save ProductCallbacks.new
  after_destroy ProductCallbacks.new

  columns_for_keyword_search :body

  validates :user, presence: true, uniqueness: { scope: :practice, message: '既に提出物があります。' }
  validates :body, presence: true

  paginates_per 50

  mentionable_as :body

  scope :ids_of_common_checked_with,
        ->(user) { where(practice: user.practices_with_checked_product).checked.pluck(:id) }

  scope :unchecked, -> { where.not(id: Check.where(checkable_type: 'Product').pluck(:checkable_id)) }
  scope :self_assigned_product, ->(current_user_id) { where(checker_id: current_user_id) }

  scope :wip, -> { where(wip: true) }
  scope :not_wip, -> { where(wip: false) }
  scope :list, lambda {
    with_avatar
      .preload([:practice, :comments, { checks: { user: { avatar_attachment: :blob } } }])
      .order(created_at: :desc)
  }
  scope :reorder_for_not_responded_products, -> { reorder(published_at: :desc, id: :desc) }

  # rubocop:disable Metrics/MethodLength
  def self.not_responded_products
    sql = <<~SQL
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
  # rubocop:enable Metrics/MethodLength

  def completed?(user)
    checks.where(user: user).present?
  end

  def change_learning_status(status)
    learning = Learning.find_or_initialize_by(
      user_id: user.id,
      practice_id: practice.id
    )
    learning.update(status: status)
  end

  def last_commented_user
    Rails.cache.fetch "/model/product/#{id}/last_commented_user" do
      commented_users.last
    end
  end

  def category(course)
    Category.category(practice: practice, course: course)
  end

  def save_checker(current_user_id)
    return false if other_checker_exists?(current_user_id)

    self.checker_id = checker_id ? nil : current_user_id
    Cache.delete_self_assigned_product_count(current_user_id)
    save!
  end

  def other_checker_exists?(current_user_id)
    checker_id.present? && checker_id.to_s != current_user_id
  end

  def checker_name
    checker_id ? User.find(checker_id).login_name : nil
  end

  def submitted_just_specific_days(date)
    if published_at.nil?
      created_at.strftime('%F') == Time.zone.today.prev_day(date).to_s
    else
      published_at.strftime('%F') == Time.zone.today.prev_day(date).to_s
    end
  end

  def submitted_over_specific_days(date)
    if published_at.nil?
      created_at.strftime('%F') == Time.zone.today.prev_day(date).to_s
    else
      published_at.strftime('%F') < Time.zone.today.prev_day(date - 1).to_s
    end
  end
end
