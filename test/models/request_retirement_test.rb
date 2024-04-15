# frozen_string_literal: true

require 'test_helper'

class RequestRetirementTest < ActiveSupport::TestCase
  test '#validate_user_existence validation' do
    request_retirement = request_retirements(:request_retirement1)
    assert request_retirement.valid?

    # invalid e-mail
    invalid_email = request_retirement.dup
    invalid_email.requester_email = 'not_exist@example.com'
    assert invalid_email.invalid?
    assert_includes invalid_email.errors.full_messages, 'メールアドレスは登録されていません。'

    # invalid requester name
    invalid_requester_name = request_retirement.dup
    invalid_requester_name.requester_name = 'Not ExistMan'
    assert invalid_requester_name.invalid?
    assert_includes invalid_requester_name.errors.full_messages, '申請者のアカウントは登録されていません。'

    # invalid target user name
    invalid_target_user_name = request_retirement.dup
    invalid_target_user_name.target_user_name = 'Not TargetMan'
    assert invalid_target_user_name.invalid?
    assert_includes invalid_target_user_name.errors.full_messages, '退会をさせる方のアカウントは登録されていません。'
  end
end
