# frozen_string_literal: true

class Announcement < ApplicationRecord
  include Commentable
  include Footprintable
  include Searchable
  include Reactionable
  include WithAvatar

  belongs_to :user
  alias_method :sender, :user

  after_create AnnouncementCallbacks.new
  after_destroy AnnouncementCallbacks.new

  validates :title, presence: true
  validates :description, presence: true
end
