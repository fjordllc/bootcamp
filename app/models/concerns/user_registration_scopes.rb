# frozen_string_literal: true

module UserRegistrationScopes
  extend ActiveSupport::Concern

  included do
    scope :classmates, lambda { |start_date, end_date|
      where(created_at: start_date..end_date).order(:created_at, :id)
    }
    scope :campaign, -> { where(created_at: Campaign.recently_campaign) }
  end
end
