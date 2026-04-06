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

  test 'mentor can see secret attributes of graduated user' do
    visit_with_auth "/users/#{users(:sotugyou).id}", 'mentormentaro'
    assert_text users(:sotugyou).email
  end

  test 'non-mentor cannot see secret attributes of graduated user' do
    visit_with_auth "/users/#{users(:sotugyou).id}", 'hatsuno'
    assert_no_text users(:sotugyou).email
  end

  test 'delete user' do
    user = users(:kimura)
    visit_with_auth "users/#{user.id}", 'komagata'
    click_link "delete-#{user.id}"
    page.driver.browser.switch_to.alert.accept
    assert_text "#{user.name} さんを削除しました。"
  end

  test 'toggles study streak visibility' do
    user = users(:hajime)
    visit_with_auth "/users/#{user.id}", 'hajime'

    initial_show_study_streak = user.show_study_streak

    assert_no_selector '.card-body', text: '現在の連続記録'
    assert_no_selector '.card-body', text: '連続最高記録'
    assert_not find('#toggle', visible: false).checked?
    find('label.a-on-off-checkbox').click

    assert_equal !initial_show_study_streak, user.reload.show_study_streak
    assert_selector '.card-body', text: '現在の連続記録'
    assert_selector '.card-body', text: '連続最高記録'
    assert find('#toggle', visible: false).checked?
    find('label.a-on-off-checkbox').click
  end

  test 'not show study streak toggle on other users profiles' do
    user = users(:hajime)
    visit_with_auth "/users/#{user.id}", 'kensyu'
    assert_no_selector 'label.a-on-off-checkbox'
    logout
    visit_with_auth "/users/#{user.id}", 'hajime'
    assert_selector 'label.a-on-off-checkbox'
  end

  test 'not show study streak toggle when no learning reports exist' do
    user = users(:kensyu)
    assert_not user.reports_with_learning_times.present?
    visit_with_auth "/users/#{user.id}", 'kensyu'
    assert_no_selector 'label.a-on-off-checkbox'
    logout
    user = users(:hajime)
    assert user.reports_with_learning_times.present?
    visit_with_auth "/users/#{user.id}", 'hajime'
    assert_selector 'label.a-on-off-checkbox'
  end
end
