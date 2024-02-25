# frozen_string_literal: true

class PostAnnouncementJob < ApplicationJob
  queue_as :default

  def perform(announcement, receivers)
    receivers.each do |receiver|
      ActivityDelivery.with(announcement:, receiver:).notify!(:post_announcement)
    end
  end
end
