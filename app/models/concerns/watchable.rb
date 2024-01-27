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
      "提出物「#{practice[:title]}」"
    when Report
      "日報「#{self[:title]}」"
    when Question
      "Q&A「#{self[:title]}」"
    when Event
      "特別イベント「#{self[:title]}」"
    when RegularEvent
      "定期イベント「#{self[:title]}」"
    when Page
      "Docs「#{self[:title]}」"
    when Announcement
      "お知らせ「#{self[:title]}」"
    end
  end

  def body
    self[:body] || self[:description]
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
