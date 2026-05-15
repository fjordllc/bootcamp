# frozen_string_literal: true

class DiscordJob < ApplicationJob
  queue_as :default

  def perform(params)
    DiscordDriver.new.call(params)
  end
end
