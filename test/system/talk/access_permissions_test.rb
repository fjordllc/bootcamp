# frozen_string_literal: true

require 'application_system_test_case'

class TalkAccessPermissionsTest < ApplicationSystemTestCase
  test 'admin can access talks page' do
    visit_with_auth '/talks', 'komagata'
    assert_equal '相談部屋 | FBC', title
  end

  test 'non-admin user cannot access talks page' do
    visit_with_auth '/talks', 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'non-admin user cannot access talks action uncompleted page' do
    visit_with_auth '/talks/action_uncompleted', 'mentormentaro'
    assert_text '管理者としてログインしてください'
  end

  test 'user who is not logged in cannot access talks page' do
    user = users(:kimura)
    visit "/talks/#{user.talk.id}"
    assert_text 'ログインしてください'
  end

  test 'talks action uncompleted page displays when admin logined ' do
    visit_with_auth '/', 'komagata'
    click_link '相談', match: :first
    assert_equal '/talks/action_uncompleted', current_path
  end

  test 'Displays users talks page when user loged in ' do
    visit_with_auth '/', 'kimura'
    click_link '相談'
    assert_text 'kimuraさんの相談部屋'
  end
end
