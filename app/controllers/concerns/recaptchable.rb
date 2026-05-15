# frozen_string_literal: true

module Recaptchable
  module V3
    extend ActiveSupport::Concern
    # NOTE: https://developers.google.com/recaptcha/docs/v3 にある初期値を使用した
    SCORE_ABOVE_THRESHOLD = 0.5

    included do
      helper_method :recaptcha_enabled?
    end

    def recaptcha_enabled?
      Recaptcha.configuration.site_key.present? && Recaptcha.configuration.secret_key.present?
    end

    def valid_recaptcha?(form_action_name)
      return true unless recaptcha_enabled?

      verify_recaptcha(
        action: form_action_name,
        minimum_score: SCORE_ABOVE_THRESHOLD,
        secret_key: Recaptcha.configuration.secret_key
      )
    rescue Recaptcha::RecaptchaError => e
      logger.error "[reCAPTCHA] #{e.message}"
      true
    end
  end
end
