# frozen_string_literal: true

class Timeline < ApplicationRecord
  include Reactionable
  belongs_to :user
  validates :context, presence: true
end
