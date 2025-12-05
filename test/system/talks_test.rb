# frozen_string_literal: true

require 'application_system_test_case'

class TalksTest < ApplicationSystemTestCase
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

  test 'a talk room is shown up on action uncompleted tab when users except admin comments there' do
    user = users(:kimura)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth "/talks/#{user.talk.id}", 'kimura'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'

    logout
    visit_with_auth '/talks', 'komagata'
    find('.page-tabs__item-link', text: '未対応').click
    assert_text "#{decorated_user.long_name} さんの相談部屋"
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

  test 'a talk room is not removed from action uncompleted tab when admin comments there' do
    user = users(:with_hyphen)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    visit '/talks/action_uncompleted'
    assert_text "#{decorated_user.long_name} さんの相談部屋"
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

  test 'Displays a list of the 10 most recent reports' do
    user = users(:hajime)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    assert_text 'ユーザーの日報'
    page.find('#side-tabs-nav-2').click
    user.reports.first(10).each do |report|
      assert_text report.title
    end
  end

  test 'talks action uncompleted page displays when admin logined ' do
    visit_with_auth '/', 'komagata'
    click_link '相談', match: :first
    assert_equal '/talks/action_uncompleted', current_path
  end

  test 'Displays users talks page when user loged in ' do
    visit_with_auth '/', 'kimura'
    click_link '相談'
    assert_text 'kimuraさんの相談部屋'
  end

  test 'push guraduation button in talk room when admin logined' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    accept_confirm do
      click_link '卒業にする'
    end
    assert_text '卒業済'
  end

  test 'admin can see tabs on user talk page' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    has_css?('page-tabs')
  end

  test 'non-admin user cannot see tabs on user talk page' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'kimura'
    has_no_css?('page-tabs')
  end

  test 'hide user icon from recent reports in talk show' do
    user = users(:hajime)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    page.find('#side-tabs-nav-2').click
    assert_no_selector('.card-list-item__user')
  end

  test 'talk show without recent reports' do
    user = users(:muryou)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    page.find('#side-tabs-nav-2').click
    assert_text '日報はまだありません。'
  end

  test 'it will be action completed when check action completed ' do
    user = users(:with_hyphen)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth '/talks/action_uncompleted', 'komagata'
    assert_text "#{decorated_user.long_name} さんの相談部屋"

    visit "/talks/#{user.talk.id}"
    find('.check-button').click
    assert_text '対応済みにしました'
    assert_text '対応済です'
    visit '/talks/action_uncompleted'
    assert_no_text "#{decorated_user.long_name} さんの相談部屋"
  end

  test 'it will be action uncompleted when check action completed ' do
    user = users(:kimura)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth '/talks/action_uncompleted', 'komagata'
    assert_no_text "#{decorated_user.long_name} さんの相談部屋"

    visit "/talks/#{user.talk.id}"
    find('.check-button').click
    assert_text '未対応にしました'
    assert_text '対応済にする'
    visit '/talks/action_uncompleted'
    assert_text "#{decorated_user.long_name} さんの相談部屋"
  end

  test 'display company-logo in consultation room when user is trainee' do
    visit_with_auth "/talks/#{talks(:talk11).id}", 'kensyu'
    assert_selector 'img[class="page-content-header__company-logo-image"]'
  end
end
