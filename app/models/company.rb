# frozen_string_literal: true

class Company < ApplicationRecord
  LOGO_SIZE = '88x88>'
  has_many :users, dependent: :nullify
  validates :name, presence: true
  has_one_attached :logo

  delegate :advisers, to: :users

  def logo_url
    if logo.attached?
      logo.variant(resize: LOGO_SIZE).processed.url
    else
      image_url('/images/companies/logos/default.png')
    end
  rescue ActiveStorage::FileNotFoundError
    image_url('/images/companies/logos/default.png')
  end
end
