# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default

  def perform(movie)
    return unless Rails.application.config.transcoder['enable']

    client = Transcoder::Client.new(movie)
    client.transcode
  end
end
