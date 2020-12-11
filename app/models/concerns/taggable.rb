# frozen_string_literal: true

module Taggable
  extend ActiveSupport::Concern

  included do
    acts_as_taggable
    validate :tag_list_validation
  end

  def tag_list_validation
    return unless tag_list.any? { |tag| tag =~ /\A(?=.*\s+|.*　+).*\z/ }

    errors.add(:tag_list, 'に空白が含まれています')
  end
end
