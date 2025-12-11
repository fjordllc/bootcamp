# frozen_string_literal: true

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  test 'push question tab for showing all the recoreded questions' do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'hatsuno'
    click_link '質問'
    assert_text '質問のタブの作り方'
    assert_text '質問のタブに関して。。。追加質問'
  end

  test 'show welcome message' do
    visit_with_auth '/', 'hatsuno'
    assert_text 'ようこそ'
  end

  test 'not show welcome message' do
    visit_with_auth '/', 'hatsuno'
    assert_text 'ようこそ'

    visit practice_path(practices(:practice1).id)
    click_button '着手'
    assert_selector '.is-started.is-active'

    visit '/'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    assert_no_text 'ようこそ'
  end

  test 'push guraduation button in user page when admin logined' do
    user = users(:kimura)
    visit_with_auth "/users/#{user.id}", 'komagata'
    accept_confirm do
      click_link '卒業にする'
    end
    assert_text '卒業済'
  end

  test 'learning time frames hidden after user graduation' do
    user = users(:kimura)
    LearningTimeFramesUser.create!(user:, learning_time_frame_id: 1)

    visit_with_auth "/users/#{user.id}", 'komagata'
    accept_confirm do
      click_link '卒業にする'
    end
    assert_text '卒業済'
    assert_no_selector 'label.a-form-label', text: '活動時間'
  end

  test 'delete user' do
    user = users(:kimura)
    visit_with_auth "users/#{user.id}", 'komagata'
    click_link "delete-#{user.id}"
    page.driver.browser.switch_to.alert.accept
    assert_text "#{user.name} さんを削除しました。"
  end
end
