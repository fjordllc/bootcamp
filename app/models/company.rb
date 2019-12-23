# frozen_string_literal: true

class Company < ActiveRecord::Base
  has_many :users
  validates :name, presence: true
  has_one_attached :logo

  def advisers
    users.advisers
  end

  def resize_logo!
    if logo.attached?
      logo.variant(resize: "88x88>").processed
    end
  end

  def logo_url
    if logo.attached?
      logo.service_url
    else
      image_url("/images/companies/logos/default.png")
    end
  end
end
