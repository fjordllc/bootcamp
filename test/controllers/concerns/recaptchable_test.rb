# frozen_string_literal: true

require 'test_helper'

class RecaptchableTest < ActiveSupport::TestCase
  class ExampleController < ApplicationController
    include Recaptchable::V3

    def recaptcha_enabled?
      true
    end
  end

  def setup
    @controller = ExampleController.new
  end

  test '#valid_recaptcha?' do
    @controller.stub(:verify_recaptcha, ->(_) { true }) do
      actual = @controller.valid_recaptcha?('submit')
      assert actual
    end

    @controller.stub(:verify_recaptcha, ->(_) { false }) do
      actual = @controller.valid_recaptcha?('submit')
      assert_not actual
    end
  end

  test '#valid_recaptcha? with error' do
    logs = []
    stub_error_logger = ->(message) { logs << message }
    stub_timeout_error = ->(_action) { raise Recaptcha::RecaptchaError, 'Recaptcha unreachable.' }
    assert_not Recaptcha.configuration.handle_timeouts_gracefully

    Rails.logger.stub(:error, stub_error_logger) do
      @controller.stub(:verify_recaptcha, stub_timeout_error) do
        actual = @controller.valid_recaptcha?('submit')
        assert actual
        assert_match '[reCAPTCHA] Recaptcha unreachable.', logs.last
      end
    end
  end
end
