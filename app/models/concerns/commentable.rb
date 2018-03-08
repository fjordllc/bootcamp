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
      self[:body][0, 50]
    end
  end

  def body
    case self
    when Report
      self[:description]
    when Product
      self[:body]
    end
  end

  def path
    case self
    when Report
      Rails.application.routes.url_helpers.polymorphic_path(self)
    when Product
      Rails.application.routes.url_helpers.polymorphic_path([self.practice, self])
    end
  end
end
