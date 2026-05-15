# frozen_string_literal: true

require 'application_system_test_case'

module Talks
  class AccessTest < ApplicationSystemTestCase
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

    test 'cannot access other users talk page' do
      visited_user = users(:hatsuno)
      visit_user = users(:mentormentaro)
      visit_with_auth talk_path(visited_user.talk), 'mentormentaro'
      assert_no_text "#{visited_user.login_name}さんの相談部屋"
      assert_text "#{visit_user.login_name}さんの相談部屋"
    end

    test 'admin can access users talk page' do
      visited_user = users(:hatsuno)
      visit_with_auth talk_path(visited_user.talk), 'komagata'
      assert_text "#{visited_user.login_name}さんの相談部屋"
    end

    test 'admin can access user talk page from talks page' do
      talk = talks(:talk7)
      talk.update!(updated_at: Time.current)
      user = talk.user
      decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
      visit_with_auth '/talks', 'komagata'
      click_link "#{decorated_user.long_name} さんの相談部屋"
      assert_selector '.page-header__title', text: 'kimura'
    end
  end
end
