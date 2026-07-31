# frozen_string_literal: true

module UserComplexQueryScopes
  extend ActiveSupport::Concern

  included do
    scope :order_by_counts, lambda { |order_by, direction|
      raise ArgumentError, 'Invalid argument' unless order_by.in?(User::VALID_SORT_COLUMNS) && direction.in?(User::VALID_SORT_COLUMNS)

      if order_by.in? %w[report comment]
        left_outer_joins(order_by.pluralize.to_sym)
          .group('users.id')
          .order(Arel.sql("count(#{order_by.pluralize}.id) #{direction}, users.created_at"))
      elsif order_by == 'created_at'
        order(order_by.to_sym => direction.to_sym)
      else
        order(order_by.to_sym => direction.to_sym, created_at: :asc)
      end
    }
    scope :active_tagged_with, lambda { |tag_name|
      with_attached_avatar
        .unretired
        .unhibernated
        .order(last_activity_at: :desc)
        .tagged_with(tag_name)
    }
  end
end
