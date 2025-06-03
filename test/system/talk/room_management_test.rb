# frozen_string_literal: true

require 'application_system_test_case'

class Talk::RoomManagementTest < ApplicationSystemTestCase
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

  test 'both public and private information is displayed' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'kimura'
    assert_no_text 'ユーザー非公開情報'
    assert_no_text 'ユーザー公開情報'

    logout
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    assert_text 'ユーザー非公開情報'
    assert_text 'ユーザー公開情報'
  end

  test 'update memo' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    assert_text 'kimuraさんのメモ'
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: '相談部屋テストメモ'
    click_button '保存する'
    assert_text '相談部屋テストメモ'
    assert_no_text 'kimuraさんのメモ'
  end

  test 'display company-logo in consultation room when user is trainee' do
    visit_with_auth "/talks/#{talks(:talk11).id}", 'kensyu'
    assert_selector 'img[class="page-content-header__company-logo-image"]'
  end
end
