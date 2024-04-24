# frozen_string_literal: true

class PracticesMovie < ApplicationRecord
  belongs_to :practice
  belongs_to :movie 
end
