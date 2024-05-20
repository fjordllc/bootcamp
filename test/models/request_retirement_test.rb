# frozen_string_literal: true

require 'test_helper'

class RequestRetirementTest < ActiveSupport::TestCase
  setup do
    # 一意性の検証をしている項目があるので、fixturesによるtestDBへの自動保存を避けるため、コード内で定義
    @request_retirement = RequestRetirement.new(
      requester_name: 'senpai',
      requester_email: 'senpai@fjord.jp',
      target_user_name: 'kensyu',
      company_name: 'company',
      reason: '退職してしまったため。',
      keep_data: true
    )
  end

  test 'setup data is valid' do
    assert @request_retirement.valid?
  end

  test 'requester name and email must match' do
    request = @request_retirement.dup
    request.requester_email = 'komagata@fjord.jp'
    request.requester_name = 'machida'
    assert request.invalid?
    assert_equal ['アカウント名とメールアドレスのユーザー情報が一致しません。'], request.errors[:base]
  end

  test 'target user is unique' do
    @request_retirement.save
    request = @request_retirement.dup
    request.target_user_name = 'kensyu'
    assert request.invalid?
    assert_equal ['既に退会申請済みのユーザーです。'], request.errors.full_messages_for(:base)
  end

  test 'set users by requester name and email and target user name' do
    request = @request_retirement.dup
    request.validate
    assert_equal User.find_by(login_name: request.requester_name), request.user
    assert_equal User.find_by(login_name: request.target_user_name), request.target_user
  end
end
