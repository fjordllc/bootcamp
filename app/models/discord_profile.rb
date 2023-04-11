# frozen_string_literal: true

class DiscordProfile < ApplicationRecord
  belongs_to :user
end
