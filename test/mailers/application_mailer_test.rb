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

    local, domain = user.email.split('@')
    assert_includes logs, "Postmarkの配信停止済みアドレスへの送信をスキップしました: [\"#{local[0]}***@#{domain}\"]"
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

    local, domain = user.email.split('@')
    assert_includes logs, "Postmarkの配信停止済みアドレスへの送信をスキップしました: [\"#{local[0]}***@#{domain}\"]"
  end

  test 'Other Postmark errors are still raised as job failures' do
    user = users(:komagata)

    Mail::TestMailer.stub_any_instance(:deliver!, lambda { |*|
      raise Postmark::InvalidEmailRequestError.new(300, '', { 'Message' => 'Invalid email request' })
    }) do
      assert_raises(Postmark::InvalidEmailRequestError) do
        UserMailer.welcome(user).deliver_now
      end
    end
  end
end
