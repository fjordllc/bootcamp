# frozen_string_literal: true

class Company < ApplicationRecord
  LOGO_SIZE = [88, 88].freeze
  has_many :users, dependent: :nullify
  validates :name, presence: true
  has_one_attached :logo

  delegate :advisers, to: :users

  def logo_url
    default_logo_path = '/images/companies/logos/default.png'
    if logo.attached?
      logo.variant(resize_to_limit: LOGO_SIZE).processed.url
    else
      image_url(default_logo_path)
    end
  rescue ActiveStorage::FileNotFoundError, ActiveStorage::InvariableError
    image_url(default_logo_path)
  end
end
