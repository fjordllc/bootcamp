# frozen_string_literal: true

class PjordProductReviewJob < ApplicationJob
  queue_as :default

  # Keep this job temporarily so jobs queued before the feature removal can be
  # deserialized safely during a rolling deployment.
  def perform(product_id:); end
end
