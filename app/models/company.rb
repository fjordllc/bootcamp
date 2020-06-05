# frozen_string_literal: true

class Company < ActiveRecord::Base
  LOGO_SIZE = "88x88>"
  has_many :users
  validates :name, presence: true
  has_one_attached :logo

  def self.all_with_empty
    Company.all.to_a.unshift(Company.new(name: "所属なし"))
  end

  def advisers
    users.advisers
  end

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
