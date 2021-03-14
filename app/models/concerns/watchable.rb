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
    end
  end

  def filter_product
    if watchable_type == 'Product'
      watchable.body
    else
      watchable.description
    end
  end

  def time
    if watchable_type == 'Report'
      watchable.reported_on
    elsif watchable.has_attribute?(:published_at) && watchable.published_at?
      watchable.published_at
    else
      watchable.created_at
    end
  end
end
