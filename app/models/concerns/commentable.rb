# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :delete_all
    has_many :commented_users,
             through: :comments,
             source: :user
  end

  def title
    case self
    when Product
      "「#{practice[:title]}」の提出物"
    else
      self[:title]
    end
  end

  def body
    case self
    when Announcement, Event, Report
      self[:description]
    else
      self[:body]
    end
  end

  def url
    case self
    when Product
      Rails.application.routes.url_helpers.product_path(self)
    when Announcement
      Rails.application.routes.url_helpers.announcement_path(self)
    when Event
      Rails.application.routes.url_helpers.event_path(self)
    when Report
      Rails.application.routes.url_helpers.report_path(self)
    else
      raise NotImplementedError, "#{self.class} does not have a defined URL path"
    end
  end
end
