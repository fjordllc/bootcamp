# frozen_string_literal: true

class Company < ApplicationRecord
  LOGO_SIZE = "88x88>"
  has_many :users
  validates :name, presence: true
  has_one_attached :logo

  delegate :advisers, to: :users

  def resize_logo!
    if logo.attached?
      logo.variant(resize: LOGO_SIZE).processed
    end
  end

  def logo_url
    if logo.attached?
      logo.variant(resize: LOGO_SIZE).service_url
    else
      image_url("/images/companies/logos/default.png")
    end
  end
end
