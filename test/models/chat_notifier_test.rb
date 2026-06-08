# frozen_string_literal: true

require 'test_helper'

class ChatNotifierTest < ActiveSupport::TestCase
  test '.message does not send when webhook URL is blank' do
    Rails.env.stub(:production?, true) do
      Discord::Notifier.stub(:message, ->(*) { flunk 'Discord notification should not be sent.' }) do
        assert_warns_missing_webhook_url { ChatNotifier.message('日報を公開しました。', webhook_url: nil) }
      end
    end
  end

  test '.notify does not send when webhook URL is blank' do
    Rails.env.stub(:production?, true) do
      Discord::Notifier.stub(:message, ->(*) { flunk 'Discord notification should not be sent.' }) do
        assert_warns_missing_webhook_url do
          ChatNotifier.notify(
            title: '日報を公開しました。',
            title_url: 'https://bootcamp.fjord.jp/reports/1',
            description: '本文',
            user: users(:komagata),
            webhook_url: ''
          )
        end
      end
    end
  end

  private

  def assert_warns_missing_webhook_url(&block)
    logs = []
    Rails.logger.stub(:warn, ->(message) { logs << message }) do
      assert_nothing_raised(&block)
    end

    assert_includes logs, 'Discord webhook URL is not configured.'
  end
end
