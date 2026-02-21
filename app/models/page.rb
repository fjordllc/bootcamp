# frozen_string_literal: true

class Page < ApplicationRecord
  include Searchable
  include WithAvatar
  include Taggable
  include Reactionable
  include Commentable
  include Watchable
  include Bookmarkable

  belongs_to :user
  belongs_to :practice, optional: true, inverse_of: :pages
  belongs_to :last_updated_user, class_name: 'User', optional: true
  has_many :watches, as: :watchable, dependent: :destroy
  validates :title, presence: true
  validates :body, presence: true
  validates :slug, length: { maximum: 200 }, format: { with: /\A[a-z][a-z0-9_-]*\z/ }, uniqueness: true, allow_nil: true
  paginates_per 20
  alias sender user
  attribute :announcement_of_publication, :boolean

  columns_for_keyword_search :title, :body

  before_validation :empty_slug_to_nil

  scope :source_cource_pages, ->(source_id) { where(practice_id: source_id) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[title body slug wip created_at updated_at user_id last_updated_user_id practice_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user practice last_updated_user comments reactions watches bookmarks]
  end

  def self.search_by_slug_or_id!(params)
    attr_name = params.start_with?(/[a-z]/) ? :slug : :id
    Page.find_by!(attr_name => params)
  end

  def description
    body # description が求められる場合は body を返す
  end

  private

  def empty_slug_to_nil
    self.slug = nil if slug && slug.empty?
  end

  scope :wip, -> { where(wip: true) }
end
