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
    find('#talks.loaded', wait: 10)
    assert_text "#{decorated_user.long_name} さんの相談部屋"
  end

  test 'a list of current students is displayed' do
    user = users(:hajime)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth '/talks?target=student_and_trainee', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text "#{decorated_user.long_name} さんの相談部屋"
  end

  test 'a list of graduates is displayed' do
    user = users(:sotugyou)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth '/talks?target=graduate', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text "#{decorated_user.long_name} さんの相談部屋"
  end

  test 'a list of advisers is displayed' do
    user = users(:advijirou)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth '/talks?target=adviser', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text "#{decorated_user.long_name} さんの相談部屋"
  end

  test 'a list of mentors is displayed' do
    user = users(:machida)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth '/talks?target=mentor', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text "#{decorated_user.long_name} さんの相談部屋"
  end

  test 'a list of trainees is displayed' do
    user = users(:kensyu)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth '/talks?target=trainee', 'komagata'
    find('#talks.loaded', wait: 10)
    assert_text "#{decorated_user.long_name} さんの相談部屋"
  end

  test 'a list of retire users is displayed' do
    user = users(:yameo)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth '/talks?target=retired', 'komagata'
    find('#talks.loaded', wait: 10)
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

  test 'Display number of comments, detail of lastest comment user' do
    visit_with_auth '/talks?target=student_and_trainee', 'komagata'
    within('.card-list-item-meta') do
      assert_text 'コメント'
      assert_selector 'img[class="a-user-icon"]'
      assert_text '（1）'
      assert_text '2019年01月02日(水) 00:00'
      assert_text '（hajime）'
    end
  end

  test 'incremental search by login_name' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimuramitai'
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by name' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'Kimura'
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'Kimura Mitai'
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by name_kana' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'キムラ'
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'キムラ ミタイ'
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by twitter_account' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimuratwitter'
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by facebook_url' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimurafacebook'
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by blog_url' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimurablog.org'
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by github_account' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimuragithub'
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by discord_account' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimuradiscord'
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by description' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: '木村さんに似ているとよく言われます。'
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search for student_or_trainee' do
    users(:kimuramitai).update!(mentor: true)
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 2

    visit '/talks?target=student_and_trainee'
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 1 # users(:kimura)
  end

  test 'incremental search for mentor' do
    users(:kimuramitai).update!(login_name: 'mentorkimura')
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'mentor'
    assert_text 'さんの相談部屋', count: 3

    visit '/talks?target=mentor'
    fill_in 'js-talk-search-input', with: 'mentor'
    assert_text 'さんの相談部屋', count: 2 # users(:mentormentaro) users(:'long-id-mentor')
  end

  test 'incremental search for graduated' do
    users(:kimuramitai).update!(login_name: 'sotugyoukimura')
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'sotugyou'
    assert_text 'さんの相談部屋', count: 3

    visit '/talks?target=graduate'
    fill_in 'js-talk-search-input', with: 'sotugyou'
    assert_text 'さんの相談部屋', count: 2 # users(:sotugyou, :sotugyou_with_job)
  end

  test 'incremental search for adviser' do
    users(:kimuramitai).update!(login_name: 'advikimura')
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'advi'
    assert_text 'さんの相談部屋', count: 3

    visit '/talks?target=adviser'
    fill_in 'js-talk-search-input', with: 'advi'
    assert_text 'さんの相談部屋', count: 2 # users(:advijirou)
  end

  test 'incremental search for trainee' do
    users(:kimuramitai).update!(login_name: 'kensyukimura')
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'kensyu'
    assert_text 'さんの相談部屋', count: 4

    visit '/talks?target=trainee'
    fill_in 'js-talk-search-input', with: 'kensyu'
    assert_text 'さんの相談部屋', count: 3 # users(:nocompanykensyu, :kensyu, :kensyuowata)
  end

  test 'incremental search for retired' do
    users(:kimuramitai).update!(login_name: 'yameokimura')
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'yameo'
    assert_text 'さんの相談部屋', count: 2

    visit '/talks?target=retired'
    fill_in 'js-talk-search-input', with: 'yameo'
    assert_text 'さんの相談部屋', count: 1 # users(:yameo)
  end

  test 'incremental search for action uncompleted' do
    users(:kimura).talk.update!(action_completed: false)
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 2

    visit '/talks/action_uncompleted'
    fill_in 'js-talk-search-input', with: 'kimura'
    assert_text 'さんの相談部屋', count: 1 # users(:kimura)
  end

  test 'switch between normal list and searched list' do
    visit_with_auth '/talks', 'komagata'
    assert_selector '.talk-list'
    assert_no_selector '.searched-talk-list'

    # /^[\w-]+$/ の場合は3文字以上、それ以外は2文字以上で検索結果を表示
    fill_in 'js-talk-search-input', with: 'kim'
    assert_no_selector '.talk-list'
    assert_selector '.searched-talk-list'

    fill_in 'js-talk-search-input', with: 'ki'
    assert_selector '.talk-list'
    assert_no_selector '.searched-talk-list'

    fill_in 'js-talk-search-input', with: 'キム'
    assert_no_selector '.talk-list'
    assert_selector '.searched-talk-list'

    fill_in 'js-talk-search-input', with: 'キ'
    assert_selector '.talk-list'
    assert_no_selector '.searched-talk-list'
  end

  test 'show no talks message when no talks found' do
    visit_with_auth '/talks', 'komagata'

    fill_in 'js-talk-search-input', with: 'hoge'
    assert_text '一致する相談部屋はありません'
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

  test 'change job seeking flag when click toggle button' do
    user = users(:hajime)

    visit_with_auth talk_path(user.talk), 'komagata'

    check '就職活動中', allow_label_click: true
    assert user.reload.job_seeking
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
    visit '/talks/action_uncompleted'
    assert_text "#{decorated_user.long_name} さんの相談部屋"
  end
end
