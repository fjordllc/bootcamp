# frozen_string_literal: true

require 'test_helper'

class WebhookTest < ActiveSupport::TestCase
  test '.construct_event' do
    expected = '12345'

    Stripe::Webhook.stub(:construct_event, { 'id' => expected }) do
      event = Webhook.construct_event(
        payload: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
        signature: 'xxxxxxxxxxxxxx',
        endpoint_secret: Rails.application.config_for(:secrets)[:stripe][:endpoint_secret]
      )

      assert_equal expected, event['id']
    end
  end

  test '.intent_url' do
    expected = 'https://dashboard.stripe.com/test/payments/abcdefg'
    assert_equal expected, Webhook.intent_url('abcdefg')

    Rails.env.stub(:production?, true) do
      expected = 'https://dashboard.stripe.com/payments/abcdefg'
      assert_equal expected, Webhook.intent_url('abcdefg')
    end
  end
end
