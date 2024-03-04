# frozen_string_literal: true

module Commentable
  include Notifiable
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
    self[:body] || self[:description]
  end
end
