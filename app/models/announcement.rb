# frozen_string_literal: true

class Announcement < ApplicationRecord
  include Commentable
  include Footprintable
  include Searchable
  include Reactionable

  belongs_to :user
  alias_method :sender, :user

  after_create AnnouncementCallbacks.new

  validates :title, presence: true
  validates :description, presence: true

  scope :with_avatar, -> { preload(user: { avatar_attachment: :blob }) }
end
