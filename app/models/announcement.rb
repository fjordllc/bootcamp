# frozen_string_literal: true

class Announcement < ApplicationRecord
  belongs_to :user
  alias_method :sender, :user

  after_create AnnouncementCallbacks.new

  validates :title, presence: true
  validates :description, presence: true
end
