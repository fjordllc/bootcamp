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
      "「#{self.practice[:title]}」の提出物"
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
end
