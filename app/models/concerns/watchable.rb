# frozen_string_literal: true

module Watchable
  include Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :watches, as: :watchable, dependent: :destroy

    scope :watched, -> { joins(:watches) }
  end

  def watched?
    watches.present?
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
