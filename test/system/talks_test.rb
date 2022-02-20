# frozen_string_literal: true

require 'application_system_test_case'

class TalksTest < ApplicationSystemTestCase
  test 'admin can access talks page' do
    visit_with_auth '/talks', 'komagata'
    assert_equal '相談部屋 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'non-admin user cannot access talks page' do
    visit_with_auth '/talks', 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'cannot access other users talk page' do
    visited_user = users(:hatsuno)
    visit_user = users(:mentormentaro)
    visit_with_auth talk_path(visited_user.talk), 'mentormentaro'
    assert_no_text "#{visited_user.name}さんの相談部屋"
    assert_text "#{visit_user.name}さんの相談部屋"
  end

  test 'admin can access users talk page' do
    visited_user = users(:hatsuno)
    visit_with_auth talk_path(visited_user.talk), 'komagata'
    assert_text "#{visited_user.name}さんの相談部屋"
  end

  test 'a talk room is shown up on unreplied tab when users except admin comments there' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'kimura'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'

    logout
    visit_with_auth '/talks', 'komagata'
    find('.page-tabs__item-link', text: '未返信').click
    assert_text "#{user.login_name} (#{user.name}) さんの相談部屋"
  end

  test 'a talk room is removed from unreplied tab when admin comments there' do
    user = users(:with_hyphen)
    visit_with_auth '/talks', 'komagata'
    click_link "#{user.login_name} (#{user.name}) さんの相談部屋"
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    visit '/talks'
    find('.page-tabs__item-link', text: '未返信').click
    assert_no_text "#{user.login_name} (#{user.name}) さんの相談部屋"
  end

  test 'a list of current students is displayed' do
    visit_with_auth '/talks?target=student_and_trainee', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text 'kimura (Kimura Tadasi) さんの相談部屋'
  end

  test 'a list of graduates is displayed' do
    visit_with_auth '/talks?target=graduate', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text 'sotugyou (卒業 太郎) さんの相談部屋'
  end

  test 'a list of advisers is displayed' do
    visit_with_auth '/talks?target=adviser', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text 'advijirou (アドバイ 次郎) さんの相談部屋'
  end

  test 'a list of mentors is displayed' do
    visit_with_auth '/talks?target=mentor', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text 'machida (Machida Teppei) さんの相談部屋'
  end

  test 'a list of trainees is displayed' do
    visit_with_auth '/talks?target=trainee', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text 'kensyu (Kensyu Seiko) さんの相談部屋'
  end

  test 'a list of retire users is displayed' do
    visit_with_auth '/talks?target=retired', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text 'yameo (辞目 辞目夫) さんの相談部屋'
  end
end
