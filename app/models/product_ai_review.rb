# frozen_string_literal: true

class ProductAiReview < ApplicationRecord
  belongs_to :product

  validates :status, inclusion: { in: %w[pending generating completed failed unconfigured cancelled] }
  validates :generation, :source_fingerprint, :model, presence: true
  around_save :silence_content_logging

  def self.fingerprint_for(product)
    practice = product.practice
    Digest::SHA256.hexdigest([product.body, practice.id, practice.title, practice.description,
                              practice.goal, practice.submission, practice.submission_answer&.description].to_json)
  end

  def current_for?(product)
    !product.wip? && source_fingerprint == self.class.fingerprint_for(product)
  end

  private

  def silence_content_logging(&block)
    if logger.respond_to?(:silence)
      logger.silence(&block)
    else
      yield
    end
  end
end
