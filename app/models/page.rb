# frozen_string_literal: true

class Page < ApplicationRecord
  include Searchable
  include WithAvatar

  belongs_to :user
  validates :title, presence: true
  validates :body, presence: true
  validate :tag_cannnot_contain_empty_character
  paginates_per 20
  alias_method :sender, :user
  after_create PageCallbacks.new
  after_update PageCallbacks.new

  columns_for_keyword_search :title, :body

  scope :wip, -> { where(wip: true) }
  acts_as_taggable

  def tag_cannnot_contain_empty_character
    if tag_list.any? { |tag| tag =~ /\A(?=.*\s+|.*　+).*\z/ }
      errors.add(:tag_list, "に空白が含まれています")
    end
  end
end
