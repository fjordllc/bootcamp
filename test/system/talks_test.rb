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

  test 'non-admin user cannot access talks unreplied page' do
    visit_with_auth '/talks/unreplied', 'mentormentaro'
    assert_text '管理者としてログインしてください'
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

  test 'both public and private information is displayed' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'kimura'
    assert_no_text 'ユーザー非公開情報'
    assert_no_text 'ユーザー公開情報'

    logout
    visit_with_auth '/talks', 'komagata'
    click_link "#{user.login_name} (#{user.name}) さんの相談部屋"
    assert_text 'ユーザー非公開情報'
    assert_text 'ユーザー公開情報'
  end

  test 'update memo' do
    user = users(:kimura)
    visit_with_auth '/talks', 'komagata'
    click_link "#{user.login_name} (#{user.name}) さんの相談部屋"
    assert_text 'kimuraさんのメモ'
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: '相談部屋テストメモ'
    click_button '保存する'
    assert_text '相談部屋テストメモ'
    assert_no_text 'kimuraさんのメモ'
  end

  test 'Displays a list of the 10 most recent reports' do
    user = users(:hajime)
    visit_with_auth '/talks', 'komagata'
    click_link "#{user.login_name} (#{user.name}) さんの相談部屋"
    assert_text 'ユーザーの日報'
    page.find('#reports_list').click
    user.reports.first(10).each do |report|
      assert_text report.title
    end
  end

  test 'talks unreplied page displays when admin logined ' do
    visit_with_auth '/', 'komagata'
    click_link '相談'
    assert_equal '/talks/unreplied', current_path
  end

  test 'Display number of comments, detail of lastest comment user' do
    visit_with_auth '/talks', 'komagata'
    within('.thread-list-item-comment') do
      assert_text 'コメント'
      assert_selector 'img[class="a-user-icon"]'
      assert_text '(1)'
      assert_text '2019年01月02日(水) 00:00'
      assert_text '(hajime)'
    end
  end
end
