# frozen_string_literal: true

class Product < ApplicationRecord # rubocop:todo Metrics/ClassLength
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

  belongs_to :practice
  belongs_to :user, touch: true
  has_many :footprints, as: :footprintable, dependent: :destroy
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

  scope :ids_of_common_checked_with,
        ->(user) { where(practice: user.practices_with_checked_product).checked.pluck(:id) }

  scope :unchecked, -> { where.not(id: Check.where(checkable_type: 'Product').pluck(:checkable_id)) }
  scope :unassigned, -> { where(checker_id: nil) }
  scope :self_assigned_product, ->(user_id) { where(checker_id: user_id) }
  scope :self_assigned_and_replied_products, ->(user_id) { self_assigned_product(user_id).where.not(id: self_assigned_no_replied_product_ids(user_id)) }

  scope :wip, -> { where(wip: true) }
  scope :not_wip, -> { where(wip: false) }
  scope :list, lambda {
    with_avatar
      .preload(:practice,
               :comments,
               { checks: { user: { avatar_attachment: :blob } } })
  }
  scope :order_for_list, -> { order(created_at: :desc, id: :desc) }
  scope :order_for_all_list, -> { order(published_at: :desc, id: :asc) }
  scope :ascending_by_date_of_publishing_and_id, -> { order(published_at: :asc, id: :asc) }
  scope :order_for_self_assigned_list, -> { order('commented_at asc nulls first, published_at asc') }
  scope :unchecked_no_replied_products, lambda {
    self_last_commented_products = where.not(commented_at: nil).filter do |product|
      product.comments.last.user_id == product.user.id
    end
    no_comments_products = where(commented_at: nil)
    no_replied_products_ids = (self_last_commented_products + no_comments_products).map(&:id)
    where(id: no_replied_products_ids).order(published_at: :asc, id: :asc)
  }
  scope :unhibernated_user_products, -> { joins(:user).where(user: { hibernated_at: nil }) }

  def self.add_latest_commented_at
    Product.all.includes(:comments).find_each do |product|
      next if product.comments.blank?

      product.update!(commented_at: product.comments.last.updated_at)
    end
  end

  # rubocop:disable Metrics/MethodLength
  def self.self_assigned_no_replied_product_ids(user_id)
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
        WHERE checker_id = ?
        AND wip = false
      )
      SELECT self_assigned_products.id
      FROM self_assigned_products
      LEFT JOIN last_comments ON self_assigned_products.id = last_comments.commentable_id
      WHERE last_comments.id IS NULL
      OR self_assigned_products.checker_id != last_comments.user_id
      ORDER BY self_assigned_products.created_at DESC
    SQL
    Product.find_by_sql([sql, user_id]).map(&:id)
  end
  # rubocop:enable Metrics/MethodLength

  def self.self_assigned_no_replied_products(user_id)
    no_replied_product_ids = self_assigned_no_replied_product_ids(user_id)
    Product.where(id: no_replied_product_ids)
           .order(published_at: :asc, id: :asc)
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

  def change_learning_status(status)
    learning = Learning.find_or_initialize_by(
      user_id: user.id,
      practice_id: practice.id
    )
    learning.update(status:)
  end

  # nilの場合あり
  def learning
    Learning.find_by(
      user_id: user.id,
      practice_id: practice.id
    )
  end

  def last_commented_user
    Rails.cache.fetch "/model/product/#{id}/last_commented_user" do
      commented_users.last
    end
  end

  def category(course)
    Category.category(practice:, course:)
  end

  def save_checker(user_id)
    return false if other_checker_exists?(user_id)

    self.checker_id = user_id
    Cache.delete_self_assigned_no_replied_product_count(user_id)
    save!
  end

  def other_checker_exists?(user_id)
    checker_id.present? && checker_id != user_id
  end

  def unassigned?
    checker_id.nil?
  end

  def checker_name
    checker&.login_name
  end

  def elapsed_days
    t = published_at || created_at
    ((Time.current - t) / 1.day).to_i
  end

  def checker_avatar
    checker&.avatar_url
  end

  def replied_status_changed?(previous_commented_user_id, current_commented_user_id)
    is_replied_by_checker_previous = checker_id == previous_commented_user_id
    is_replied_by_checker_current = checker_id == current_commented_user_id

    is_replied_by_checker_previous != is_replied_by_checker_current
  end

  def update_last_commented_at(comment)
    if comment
      if comment.user.mentor
        update_columns(mentor_last_commented_at: comment.updated_at) # rubocop:disable Rails/SkipsModelValidations
      elsif comment.user == user
        update_columns(self_last_commented_at: comment.updated_at) # rubocop:disable Rails/SkipsModelValidations
      end
    else
      update_columns(mentor_last_commented_at: nil, self_last_commented_at: nil) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def update_commented_at(comment)
    update_columns(commented_at: comment&.updated_at) # rubocop:disable Rails/SkipsModelValidations
  end

  def delete_last_commented_at
    update_last_commented_at(comments.last)
  end

  def delete_commented_at
    update_commented_at(comments.last)
  end

  def notification_type
    updated_after_submission? ? :product_update : :submitted
  end

  def updated_after_submission?
    return false if saved_change_to_attribute?('published_at', from: nil)

    created_at != updated_at
  end

  def url
    Rails.application.routes.url_helpers.product_path(self)
  end

  def formatted_summary(word)
    return body unless word.present?

    body.gsub(/(#{Regexp.escape(word)})/i, '<strong class="matched_word">\1</strong>')
  end
end
