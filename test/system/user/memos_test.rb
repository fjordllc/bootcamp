# frozen_string_literal: true

require 'application_system_test_case'

class User::MemoTest < ApplicationSystemTestCase
  setup do
    @memo = MentorMemo.create!(
      recipient: users(:kimura),
      writer: users(:mentormentaro),
      body: 'kimuraさんのメモ'
    )
  end

  test 'add memo' do
    visit_with_auth user_path(users(:kimura)), 'mentormentaro'
    click_button '追加'
    fill_in 'js-new-memo', with: '新しいメモ'
    click_button '保存する'
    assert_text '新しいメモ'
  end

  test 'update memo' do
    visit_with_auth user_path(users(:kimura)), 'mentormentaro'
    assert_text 'kimuraさんのメモ'

    within(".mentor-memo[data-memo_id='#{@memo.id}']") do
      click_button '編集'
      fill_in "js-memo-#{@memo.id}", with: '編集されたメモ'
      click_button '保存する'
    end
    assert_text '編集されたメモ'
    assert_no_text 'kimuraさんのメモ'
  end

  test 'delete memo' do
    visit_with_auth user_path(users(:kimura)), 'mentormentaro'
    assert_text 'kimuraさんのメモ'

    within(".mentor-memo[data-memo_id='#{@memo.id}']") do
      accept_confirm do
        click_button '削除'
      end
    end
    assert_no_text 'kimuraさんのメモ'
  end

  test 'admin can edit and delete others memo' do
    visit_with_auth user_path(users(:kimura)), 'komagata'
    assert_button '編集'
    assert_button '削除'
  end

  test 'non writer cannot edit or delete memo' do
    visit_with_auth user_path(users(:kimura)), 'long-id-mentor'
    assert_no_button '編集'
    assert_no_button '削除'
  end

  test 'cancel editing does not update memo' do
    visit_with_auth user_path(users(:kimura)), 'mentormentaro'
    assert_text 'kimuraさんのメモ'

    within(".mentor-memo[data-memo_id='#{@memo.id}']") do
      click_button '編集'
      fill_in "js-memo-#{@memo.id}", with: '編集されたメモ'
      click_button 'キャンセル'
    end
    assert_text 'kimuraさんのメモ'
    assert_no_text '編集されたメモ'
  end

  test 'can preview while editing memo' do
    visit_with_auth user_path(users(:kimura)), 'mentormentaro'
    assert_text 'kimuraさんのメモ'

    within(".mentor-memo[data-memo_id='#{@memo.id}']") do
      click_button '編集'
      fill_in "js-memo-#{@memo.id}", with: 'プレビューができます。'
      find('.form-tabs__tab', text: 'プレビュー').click
    end
    assert_text 'プレビューができます。'
  end

  test 'show empty message when no memos' do
    visit_with_auth user_path(users(:hajime)), 'mentormentaro'
    assert_text 'ユーザーメモはまだありません。'
    assert_no_selector '.mentor-memo'
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
