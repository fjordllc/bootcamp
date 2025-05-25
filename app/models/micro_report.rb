# frozen_string_literal: true

class MicroReport < ApplicationRecord
  include Reactionable

  belongs_to :user
  validates :content, presence: true
end
