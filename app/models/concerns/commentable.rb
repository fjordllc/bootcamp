# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :delete_all
  end

  def title
    case self
    when Report
      self[:title]
    when Product
      "「#{self.practice[:title]}」の提出物"
    when Announcement
      self[:title]
    end
  end

  def body
    case self
    when Report
      self[:description]
    when Product
      self[:body]
    when Announcement
      self[:description]
    end
  end
end
