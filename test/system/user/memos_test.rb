# frozen_string_literal: true

require 'application_system_test_case'

class User::MemoTest < ApplicationSystemTestCase
  test 'update memo' do
    visit_with_auth user_path(users(:hatsuno)), 'komagata'
    assert_text 'ユーザーメモはまだありません。'
    find('.user-mentor-memo__new-input').set 'ユーザーメンターメモ'
    click_button '追加'
    assert_text 'ユーザーメンターメモ'
    assert_no_text 'ユーザーメモはまだありません。'
  end

  test 'do not update memo when cancel' do
    visit_with_auth user_path(users(:kimura)), 'komagata'
    assert_text 'この生徒は英語が得意です。'
    assert_no_text 'ユーザーメモはまだありません。'
    click_button '編集'
    within('.user-mentor-memo__items') do
      find('textarea').set('ユーザーメンターメモ')
    end
    click_button 'キャンセル'
    assert_no_text 'ユーザーメンターメモ'
    assert_text 'この生徒は英語が得意です。'
    assert_no_text 'ユーザーメモはまだありません。'
  end

  test 'cancelling one memo edit does not reload the page and keeps other unsaved input' do
    visit_with_auth user_path(users(:kimura)), 'komagata'
    find('.user-mentor-memo__new-input').set '書きかけの新規メモ'
    click_button '編集'
    within('.user-mentor-memo__items') do
      find('textarea').set('編集中の内容')
    end
    click_button 'キャンセル'
    assert_equal '書きかけの新規メモ', find('.user-mentor-memo__new-input').value
  end

  test 'renders memo content as markdown' do
    visit_with_auth user_path(users(:hatsuno)), 'komagata'
    assert_text 'ユーザーメモはまだありません。'
    find('.user-mentor-memo__new-input').set '**太字のメモ**'
    click_button '追加'
    within('.user-mentor-memo__items') do
      assert_selector 'strong', text: '太字のメモ'
    end
  end

  test 'shows markdown preview while editing memo' do
    visit_with_auth user_path(users(:kimura)), 'komagata'
    click_button '編集'
    within('.user-mentor-memo__items') do
      find('textarea').set('**プレビュー確認**')
      find('.a-form-tabs__tab', text: 'プレビュー').click
      assert_selector '.a-markdown-input__preview strong', text: 'プレビュー確認'
    end
  end

  test 'shows unknown created_at for migrated memo at the bottom of the list' do
    visit_with_auth user_path(users(:kimura)), 'komagata'
    within('.user-mentor-memo__items') do
      assert_selector '.user-mentor-memo-item:last-child', text: '作成日不明'
      assert_selector '.user-mentor-memo-item:last-child', text: mentor_memos(:migrated_kimura).content
    end
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
