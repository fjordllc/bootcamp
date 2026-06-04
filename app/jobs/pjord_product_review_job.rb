# frozen_string_literal: true

class PjordProductReviewJob < ApplicationJob
  queue_as :default
  retry_on RubyLLM::Error, Faraday::Error, Net::OpenTimeout, Net::ReadTimeout, wait: :polynomially_longer, attempts: 3
  discard_on ActiveJob::DeserializationError

  def perform(product_id:)
    product = Product.find_by(id: product_id)
    return if product.nil?

    pjord = Pjord.user
    return if pjord.nil?

    response = Pjord::ProductReviewAgent.review(product)
    return if response.blank?

    Comment.create!(user: pjord, commentable: product, description: response)
  end
end
