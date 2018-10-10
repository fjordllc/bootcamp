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
      I18n.translate("practice's_product", practice: self.practice[:title])
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
    when Product
      Rails.application.routes.url_helpers.polymorphic_path([self.practice, self])
    else
      Rails.application.routes.url_helpers.polymorphic_path(self)
    end
  end
end
