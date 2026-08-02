# frozen_string_literal: true

module UserComplexQueryScopes
  extend ActiveSupport::Concern

  included do
    scope :active_tagged_with, lambda { |tag_name|
      with_attached_avatar
        .unretired
        .unhibernated
        .order(last_activity_at: :desc)
        .tagged_with(tag_name)
    }
  end
end
