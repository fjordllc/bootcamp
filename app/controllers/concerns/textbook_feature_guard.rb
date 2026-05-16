# frozen_string_literal: true

# textbook機能のfeature flag制御
module TextbookFeatureGuard
  extend ActiveSupport::Concern

  private

  def require_textbook_enabled
    return if Switchlet.enabled?(:textbook) || Rails.env.local? || staging_or_review?

    head :not_found
  end

  def staging_or_review?
    ENV['REVIEW_APP'].present? || ENV['STAGING'].present?
  end
end
