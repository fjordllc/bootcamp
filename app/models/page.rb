# frozen_string_literal: true

class Page < ApplicationRecord
  include Searchable
  include WithAvatar
  include Taggable
  include Reactionable
  include Commentable

  belongs_to :user
  belongs_to :last_updated_user, class_name: "User", optional: true
  validates :title, presence: true
  validates :body, presence: true
  paginates_per 20
  alias_method :sender, :user
  after_create PageCallbacks.new
  after_update PageCallbacks.new

  columns_for_keyword_search :title, :body

  scope :wip, -> { where(wip: true) }
end
