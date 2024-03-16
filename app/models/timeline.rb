# frozen_string_literal: true

class Timeline < ApplicationRecord
  include Reactionable

  belongs_to :user
end
