# frozen_string_literal: true

class PjordProductReviewJob < ApplicationJob
  queue_as :default
  retry_on RubyLLM::Error, Faraday::Error, Net::OpenTimeout, Net::ReadTimeout, wait: :polynomially_longer, attempts: 3
  discard_on ActiveJob::DeserializationError

  def perform(product_id:)
    product = Product.find_by(id: product_id)
    return if product.nil?
    return unless product.practice.pjord_review?

    pjord = Pjord.user
    return if pjord.nil?

    response = Pjord::ProductReviewAgent.review_result(product)
    body = response[:body]
    return if body.blank?

    Comment.create!(user: pjord, commentable: product, description: body)
    auto_check_product(product, pjord) if product.practice.pjord_auto_check? && response[:auto_check]
  end

  private

  def auto_check_product(product, pjord)
    return if product.checked?

    check = Check.create!(user: pjord, checkable: product)
    product.checks.reload
    ActiveSupport::Notifications.instrument('check.create', check:)
  end
end
