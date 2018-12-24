# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :delete_all
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
    when Product
      self[:body]
    else
      self[:description]
    end
  end
end
