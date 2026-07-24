# frozen_string_literal: true

class ReportPreset < ApplicationRecord
  self.table_name = 'report_templates'

  belongs_to :user

  validates :description, presence: true
  validates :user, presence: true
end
