# frozen_string_literal: true

class Bookmark < ApplicationRecord
  BOOKMARKABLE_CLASSES = {
    'Announcement' => Announcement,
    'Page' => Page,
    'Talk' => Talk,
    'Movie' => Movie,
    'RegularEvent' => RegularEvent,
    'Event' => Event,
    'Product' => Product,
    'Question' => Question,
    'Report' => Report
  }.freeze

  belongs_to :user
  belongs_to :bookmarkable, polymorphic: true

  validates :user_id, uniqueness: { scope: %i[bookmarkable_id bookmarkable_type] }

  def self.bookmarkable_class(type)
    BOOKMARKABLE_CLASSES[type] if type.is_a?(String)
  end
end
