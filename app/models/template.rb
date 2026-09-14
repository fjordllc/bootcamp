# frozen_string_literal: true

class Template < ApplicationRecord
  belongs_to :templatable, polymorphic: true

  validates :description, presence: true
end
