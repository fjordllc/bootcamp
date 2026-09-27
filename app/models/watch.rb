# frozen_string_literal: true

class Watch < ApplicationRecord
  WATCHABLE_TYPES = %w[
    Announcement
    Event
    Movie
    Page
    PairWork
    Practice
    Product
    Question
    RegularEvent
    Report
  ].freeze

  belongs_to :user, touch: true
  belongs_to :watchable, polymorphic: true

  validates :watchable_type, inclusion: { in: WATCHABLE_TYPES }
  validates :user_id, uniqueness: { scope: %i[watchable_id watchable_type] }
  validates :watchable_type, :watchable_id, :user_id, presence: true

  def self.watchable_class_for(type)
    return unless WATCHABLE_TYPES.include?(type)

    polymorphic_class_for(type)
  end
end
