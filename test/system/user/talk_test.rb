# frozen_string_literal: true

require 'application_system_test_case'

class User::TalkTest < ApplicationSystemTestCase
  test 'cannot access other users talk page' do
    visited_user = users(:hatsuno)
    visit_user = users(:yamada)
    visit_with_auth user_talk_path(visited_user), 'yamada'
    assert_no_text "#{visited_user.name}さんの相談部屋"
    assert_text "#{visit_user.name}さんの相談部屋"
  end

  test 'admin can access users talk page' do
    visited_user = users(:hatsuno)
    visit_with_auth user_talk_path(visited_user), 'komagata'
    assert_text "#{visited_user.name}さんの相談部屋"
  end
end
