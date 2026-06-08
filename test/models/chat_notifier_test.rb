# frozen_string_literal: true

require 'test_helper'

class ChatNotifierTest < ActiveSupport::TestCase
  test '.message does not send when webhook URL is blank' do
    Rails.env.stub(:production?, true) do
      Discord::Notifier.stub(:message, ->(*) { flunk 'Discord notification should not be sent.' }) do
        assert_nothing_raised do
          ChatNotifier.message('日報を公開しました。', webhook_url: nil)
        end
      end
    end
  end

  test '.notify does not send when webhook URL is blank' do
    Rails.env.stub(:production?, true) do
      Discord::Notifier.stub(:message, ->(*) { flunk 'Discord notification should not be sent.' }) do
        assert_nothing_raised do
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
end
