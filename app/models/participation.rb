# frozen_string_literal: true

class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :event
end
