# frozen_string_literal: true

module ProductStatus
  extend ActiveSupport::Concern

  included do
    scope :ids_of_common_checked_with,
          ->(user) { where(practice: user.practices_with_checked_product).checked.pluck(:id) }

    scope :unchecked, -> { where.not(id: Check.where(checkable_type: 'Product').pluck(:checkable_id)) }
    scope :unassigned, -> { where(checker_id: nil) }
    scope :self_assigned_product, ->(user_id) { where(checker_id: user_id) }
    scope :self_assigned_and_replied_products, lambda { |user_id|
      self_assigned_product(user_id)
        .where.not(id: ProductSelfAssignedNoRepliedQuery.new(user_id:).call.select(:id).reorder(nil))
    }

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
    scope :unhibernated_user_products, -> { joins(:user).where(user: { hibernated_at: nil }) }
  end
end
