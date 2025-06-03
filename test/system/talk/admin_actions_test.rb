# frozen_string_literal: true

require 'application_system_test_case'

class TalkAdminActionsTest < ApplicationSystemTestCase
  test 'push guraduation button in talk room when admin logined' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    accept_confirm do
      click_link '卒業にする'
    end
    assert_text '卒業済'
  end
end
