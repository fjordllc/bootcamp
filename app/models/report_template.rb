# frozen_string_literal: true

class ReportTemplate < ApplicationRecord
  belongs_to :user

  validates :description, presence: true
  validates :user, presence: true
end
