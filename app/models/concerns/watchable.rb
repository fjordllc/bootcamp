# frozen_string_literal: true

module Watchable
  extend ActiveSupport::Concern

  included do
    has_many :watches, as: :watchable, dependent: :destroy

    scope :watched, -> { joins(:watches) }
  end

  def watched?
    watches.present?
  end

  def notification_title
    case self
    when Product
      "「#{self.practice[:title]}」の提出物"
    when Report
      "「#{self[:title]}」の日報"
    when Question
      "「#{self[:title]}」のQ&A"
    when Event
      "「#{self[:title]}」のイベント"
    else
      self[:title]
    end
  end
end
