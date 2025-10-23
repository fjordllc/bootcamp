# frozen_string_literal: true

class Company < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper

  LOGO_SIZE = [88, 88].freeze
  has_many :users, dependent: :nullify
  validates :name, presence: true
  has_one_attached :logo

  delegate :advisers, to: :users

  def logo_url
    if logo.attached?
      logo.variant(resize_to_limit: LOGO_SIZE, format: :webp).processed.url
    else
      image_url('/images/companies/logos/default.png')
    end
  rescue ActiveStorage::FileNotFoundError
    image_url('/images/companies/logos/default.png')
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name description created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[users]
  end
end
