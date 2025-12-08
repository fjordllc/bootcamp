# frozen_string_literal: true

require 'application_system_test_case'

module AutoRetire
  class NotificationTest < ApplicationSystemTestCase
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'retire with postmark error' do
      user = users(:kyuukai)
      logs = []
      stub_warn_logger = ->(message) { logs << message }
      Rails.logger.stub(:warn, stub_warn_logger) do
        stub_postmark_error = ->(_user) { raise Postmark::InactiveRecipientError }
        UserMailer.stub(:auto_retire, stub_postmark_error) do
          travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
            VCR.use_cassette 'subscription/update' do
              Card.stub(:destroy_all, true) do
                mock_env('TOKEN' => 'token') do
                  visit scheduler_daily_auto_retire_path(token: 'token')
                end
              end
            end
            assert_equal Date.current, user.reload.retired_on
          end
        end
      end
      assert_match '[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：', logs.to_s
    end

    test 'send mail one week before auto retire' do
      travel_to Time.zone.local(2020, 3, 26, 0, 0, 0) do
        mock_env('TOKEN' => 'token') do
          visit scheduler_daily_send_mail_to_hibernation_user_path(token: 'token')
        end
      end

      user = users(:kyuukai)
      mails = ActionMailer::Base.deliveries
      mail_to_user = mails.find { |m| m.to == [user.email] }
      assert_equal '[FBC] ご注意：休会期限の接近について', mail_to_user.subject
    end
  end
end
