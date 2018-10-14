# frozen_string_literal: true

class Announcement < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :description, presence: true
end
