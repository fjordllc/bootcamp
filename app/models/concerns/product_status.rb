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
  end
end
