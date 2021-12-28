# frozen_string_literal: true

class Page < ApplicationRecord
  include Searchable
  include WithAvatar
  include Taggable
  include Reactionable
  include Commentable
  include Watchable
  include Bookmarkable
  include Taskable

  belongs_to :user
  belongs_to :practice, optional: true
  belongs_to :last_updated_user, class_name: 'User', optional: true
  has_many :watches, as: :watchable, dependent: :destroy
  validates :title, presence: true
  validates :body, presence: true
  validates :slug, length: { maximum: 200 }, format: { with: /\A[a-z][a-z0-9_-]*\z/ }, uniqueness: true, allow_nil: true
  paginates_per 20
  alias sender user
  after_create PageCallbacks.new
  after_update PageCallbacks.new

  columns_for_keyword_search :title, :body

  before_validation :empty_slug_to_nil

  def self.search_by_slug_or_id(params)
    attr_name = params.start_with?(/[a-z]/) ? :slug : :id
    Page.find_by(attr_name => params)
  end

  private

  def empty_slug_to_nil
    self.slug = nil if slug && slug.empty?
  end

  scope :wip, -> { where(wip: true) }
end
