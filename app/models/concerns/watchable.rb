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
      "「#{practice[:title]}」の提出物"
    when Report
      "「#{self[:title]}」の日報"
    when Question
      "「#{self[:title]}」のQ&A"
    when Event
      "「#{self[:title]}」のイベント"
    when Page
      "「#{self[:title]}」のDocs"
    when Announcement
      " [#{self[:title]}]のお知らせ"
    end
  end

  def body
    case self
    when Question, Event, Report, Announcement
      self[:description]
    else
      self[:body]
    end
  end

  def time
    if instance_of?(Report)
      self[:reported_on]
    elsif has_attribute?(:published_at) && published_at?
      self[:published_at]
    else
      self[:created_at]
    end
  end
end
