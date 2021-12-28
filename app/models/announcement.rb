# frozen_string_literal: true

class Announcement < ApplicationRecord
  include Commentable
  include Footprintable
  include Searchable
  include Reactionable
  include WithAvatar
  include Watchable
  include Taskable

  enum target: {
    all: 0,
    students: 1,
    job_seekers: 2
  }, _prefix: true

  has_many :watches, as: :watchable, dependent: :destroy
  belongs_to :user
  alias sender user

  after_create AnnouncementCallbacks.new
  after_update AnnouncementCallbacks.new
  after_destroy AnnouncementCallbacks.new

  validates :title, presence: true
  validates :description, presence: true
  validates :target, presence: true

  columns_for_keyword_search :title, :description
end
