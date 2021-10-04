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
  include Bookmarkable

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
  scope :unassigned, -> { where(checker_id: nil) }
  scope :self_assigned_product, ->(current_user_id) { where(checker_id: current_user_id) }

  scope :wip, -> { where(wip: true) }
  scope :not_wip, -> { where(wip: false) }
  scope :list, lambda {
    with_avatar
      .preload(:practice,
               :comments,
               { user: :company },
               { checks: { user: { avatar_attachment: :blob } } })
  }
  scope :order_for_list, -> { order(created_at: :desc, id: :desc) }
  scope :order_for_not_wip_list, -> { order(published_at: :desc, id: :desc) }

  # rubocop:disable Metrics/MethodLength
  def self.not_responded_product_ids
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
    Product.find_by_sql(sql).map(&:id)
  end
  # rubocop:enable Metrics/MethodLength

  def self.not_responded_products
    Product.where(id: not_responded_product_ids)
  end

  def self.add_latest_commented_at
    Product.all.includes(:comments).find_each do |product|
      next if product.comments.blank?

      product.update!(commented_at: product.comments.last.updated_at)
    end
  end

  # rubocop:disable Metrics/MethodLength
  def self.self_assigned_no_replied_product_ids(current_user_id)
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
      self_assigned_products AS (
        SELECT products.*
        FROM products
        WHERE checker_id = #{current_user_id}
      )
      SELECT self_assigned_products.id
      FROM self_assigned_products
      LEFT JOIN last_comments ON self_assigned_products.id = last_comments.commentable_id
      WHERE last_comments.id IS NULL
      OR self_assigned_products.checker_id != last_comments.user_id
      ORDER BY self_assigned_products.created_at DESC
    SQL
    Product.find_by_sql(sql).map(&:id)
  end
  # rubocop:enable Metrics/MethodLength

  def self.self_assigned_no_replied_products(current_user_id)
    no_replied_product_ids = self_assigned_no_replied_product_ids(current_user_id)
    Product.where(id: no_replied_product_ids)
           .order(created_at: :desc)
  end

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
    Cache.delete_self_assigned_no_replied_product_count(current_user_id)
    save!
  end

  def other_checker_exists?(current_user_id)
    checker_id.present? && checker_id.to_s != current_user_id
  end

  def checker_name
    checker_id ? User.find(checker_id).login_name : nil
  end

  def elapsed_days
    t = published_at || created_at
    ((Time.current - t) / 1.day).to_i
  end

  def checker_avatar
    checker_id ? User.find(checker_id).avatar_url : nil
  end
end
