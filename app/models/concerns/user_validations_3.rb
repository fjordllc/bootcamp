# frozen_string_literal: true

module UserValidations3
  extend ActiveSupport::Concern

  included do
    enum :referral_source, {
      search_engine: 0,
      referral: 1,
      event: 2,
      x: 3,
      facebook: 4,
      blog: 5,
      web_ad: 6,
      other: 99
    }, prefix: true

    enum :career_path, {
      unset: 0,
      job_seeking: 1,
      employed_via_referral: 2,
      employed_without_referral: 3,
      employed_non_it: 4,
      internal_transfer_to_programmer: 5,
      not_employed: 6
    }, prefix: true

    after_create UserCallbacks.new
    before_validation :convert_blank_of_address_to_nil
  end
end
