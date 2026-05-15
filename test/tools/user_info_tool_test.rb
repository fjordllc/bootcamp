# frozen_string_literal: true

require 'test_helper'

class UserInfoToolTest < ActiveSupport::TestCase
  setup do
    @tool = UserInfoTool.new
  end

  test 'returns user profile info' do
    user = users(:komagata)
    result = @tool.execute(login_name: user.login_name)
    assert_includes result, 'プロフィール'
    assert_includes result, user.login_name
  end

  test 'returns curriculum progress for student' do
    user = users(:kimura)
    result = @tool.execute(login_name: user.login_name)
    assert_includes result, 'カリキュラム進捗'
    assert_includes result, '進捗率'
  end

  test 'does not return progress for admin' do
    user = users(:komagata)
    result = @tool.execute(login_name: user.login_name)
    assert_not_includes result, 'カリキュラム進捗'
  end

  test 'returns activity info' do
    user = users(:kimura)
    result = @tool.execute(login_name: user.login_name)
    assert_includes result, '最近の活動'
  end

  test 'returns not found for unknown user' do
    result = @tool.execute(login_name: 'nonexistent_user_12345')
    assert_includes result, '見つかりませんでした'
  end

  test 'includes role label' do
    admin = users(:komagata)
    result = @tool.execute(login_name: admin.login_name)
    assert_includes result, '管理者'
  end
end
