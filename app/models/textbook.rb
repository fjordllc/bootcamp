# frozen_string_literal: true

class Textbook < ApplicationRecord
  has_many :chapters, class_name: 'Textbook::Chapter', dependent: :destroy
  belongs_to :practice, optional: true

  validates :title, presence: true

  scope :published, -> { where(published: true) }
end
