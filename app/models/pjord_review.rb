# frozen_string_literal: true

class PjordReview
  def self.call(product:, wip_before_save:)
    new(product:, wip_before_save:).call
  end

  def initialize(product:, wip_before_save:)
    @product = product
    @wip_before_save = wip_before_save
  end

  def call
    return unless submitted_on_save?
    return unless product.practice.pjord_review?

    PjordProductReviewJob.perform_later(product_id: product.id)
  end

  private

  attr_reader :product, :wip_before_save

  def submitted_on_save?
    created_as_submitted? || changed_from_wip_to_submitted?
  end

  def created_as_submitted?
    wip_before_save.nil? && !product.wip?
  end

  def changed_from_wip_to_submitted?
    wip_before_save && !product.wip?
  end
end
