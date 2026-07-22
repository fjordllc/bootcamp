# frozen_string_literal: true

require 'application_system_test_case'

class User::MemoTest < ApplicationSystemTestCase
  test 'update memo' do
    visit_with_auth user_path(users(:hatsuno)), 'komagata'
    assert_text 'ユーザーメモはまだありません。'
    find('.user-mentor-memo-new-input').set 'ユーザーメンターメモ'
    click_button '追加'
    assert_text 'ユーザーメンターメモ'
    assert_no_text 'ユーザーメモはまだありません。'
  end

  test 'do not update memo when cancel' do
    visit_with_auth user_path(users(:kimura)), 'komagata'
    assert_text 'この生徒は英語が得意です。'
    assert_no_text 'ユーザーメモはまだありません。'
    click_button '編集'
    within('.user-mentor-memo-items') do
      find('input[type=text]').set('ユーザーメンターメモ')
    end
    click_button 'キャンセル'
    assert_no_text 'ユーザーメンターメモ'
    assert_text 'この生徒は英語が得意です。'
    assert_no_text 'ユーザーメモはまだありません。'
  end

  test 'admin can see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'komagata'
    assert_text 'メンター向けユーザーメモ'
  end

  test 'mentor can see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'mentormentaro'
    assert_text 'メンター向けユーザーメモ'
  end

  test 'adviser can’t see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'advijirou'
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'trainee can’t see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'kensyu'
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'graduate can’t see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'sotugyou'
    assert_no_text 'メンター向けユーザーメモ'
  end

  test 'student can’t see memo' do
    visit_with_auth user_path(users(:hatsuno)), 'hatsuno'
    assert_no_text 'メンター向けユーザーメモ'
  end
end
