# frozen_string_literal: true

class ProductAiReview < ApplicationRecord
  belongs_to :product

  around_save :silence_content_logging

  private

  def silence_content_logging(&block)
    if logger.respond_to?(:silence)
      logger.silence(&block)
    else
      yield
    end
  end
end
