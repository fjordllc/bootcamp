# frozen_string_literal: true

require 'test_helper'

class ApplicationMailerTest < ActionMailer::TestCase
  test 'Mail to inactive address' do
    user = users(:komagata)
    logs = []

    Rails.logger.stub(:info, ->(message) { logs << message }) do
      Mail::TestMailer.stub_any_instance(:deliver!, lambda { |*|
        raise Postmark::InactiveRecipientError.new(406, '', { 'Message' => "Found inactive addresses: #{user.email}. Inactive" })
      }) do
        assert_nothing_raised do
          UserMailer.welcome(user).deliver_now
        end
      end
    end

    assert_includes logs, [user.email].to_s
  end

  test 'Mail to inactive address via deliver_later' do
    user = users(:komagata)
    logs = []

    Rails.logger.stub(:info, ->(message) { logs << message }) do
      Mail::TestMailer.stub_any_instance(:deliver!, lambda { |*|
        raise Postmark::InactiveRecipientError.new(406, '', { 'Message' => "Found inactive addresses: #{user.email}. Inactive" })
      }) do
        perform_enqueued_jobs do
          assert_nothing_raised do
            UserMailer.welcome(user).deliver_later
          end
        end
      end
    end

    assert_includes logs, [user.email].to_s
  end
end
