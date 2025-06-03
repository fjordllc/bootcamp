# frozen_string_literal: true

require 'application_system_test_case'

class UserListTest < ApplicationSystemTestCase
  test 'show listing all users' do
    visit_with_auth users_path, 'kimura'
    assert_equal '全てのユーザー | FBC', title
    assert_selector 'h2.page-header__title', text: 'ユーザー'
  end

  test 'show inactive message on users page' do
    travel_to Time.zone.local(2014, 1, 1, 0, 0, 0) do
      visit_with_auth '/', 'kimura'
    end

    visit_with_auth '/users', 'komagata'
    assert_no_selector 'div.users-item.inactive'
    assert_text '1ヶ月以上ログインがありません'

    visit_with_auth '/users', 'hatsuno'
    assert_selector '.page-header__title', text: 'ユーザー'
    assert_no_selector 'div.users-item.inactive'
    assert_no_text '1ヶ月以上ログインがありません'
  end

  test 'incremental search by login_name' do
    visit_with_auth '/users', 'komagata'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'kimura'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura Tadasi', count: 1
  end

  test 'incremental search by name' do
    visit_with_auth '/users', 'kimura'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'Shinji'
    find('#js-user-search-input').send_keys :return
    assert_text 'Hatsuno Shinji', count: 1
  end

  test 'incremental search by name_kana' do
    visit_with_auth '/users', 'mentormentaro'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'キムラ ミタイ'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura Mitai', count: 1
  end

  test 'incremental search by twitter_account' do
    visit_with_auth '/users', 'komagata'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'hatsuno'
    find('#js-user-search-input').send_keys :return
    assert_text 'Hatsuno Shinji', count: 1
  end

  test 'incremental search by blog_url' do
    visit_with_auth '/users', 'komagata'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'hatsuno.org'
    find('#js-user-search-input').send_keys :return
    assert_text 'Hatsuno Shinji', count: 1
  end

  test 'incremental search by github_account' do
    visit_with_auth '/users', 'komagata'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'kananashi'
    find('#js-user-search-input').send_keys :return
    assert_text 'ユーザーです 読み方のカナが無い', count: 1
  end

  test 'incremental search by facebook_url' do
    visit_with_auth '/users', 'komagata'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'kimurafacebook'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura Mitai', count: 1
  end

  test 'incremental search by description' do
    visit_with_auth '/users', 'komagata'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: '木村です'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura Tadasi', count: 1
  end

  test 'search only mentor when target is mentor' do
    visit_with_auth '/users?target=mentor', 'komagata'
    assert_selector '.users-item', count: 4
    fill_in 'js-user-search-input', with: 'machida'
    find('#js-user-search-input').send_keys :return
    assert_text 'Machida Teppei', count: 1

    fill_in 'js-user-search-input', with: 'kimura'
    find('#js-user-search-input').send_keys :return
    assert_text '一致するユーザーはいません'
  end

  test 'search only graduated students when target is graduate' do
    visit_with_auth '/users?target=graduate', 'komagata'
    assert_selector '.users-item', count: 4
    fill_in 'js-user-search-input', with: '卒業 就職済美'
    find('#js-user-search-input').send_keys :return
    assert_text '卒業 就職済美', count: 1

    fill_in 'js-user-search-input', with: 'kimura'
    find('#js-user-search-input').send_keys :return
    assert_text '一致するユーザーはいません'
  end

  test 'search only adviser when target is adviser' do
    visit_with_auth '/users?target=adviser', 'komagata'
    assert_selector '.users-item', count: 4
    fill_in 'js-user-search-input', with: 'advijirou'
    find('#js-user-search-input').send_keys :return
    assert_text 'アドバイ 次郎', count: 1

    fill_in 'js-user-search-input', with: 'kimura'
    find('#js-user-search-input').send_keys :return
    assert_text '一致するユーザーはいません'
  end

  test 'search only retired when target is retired' do
    visit_with_auth '/users?target=retired', 'komagata'
    assert_selector '.users-item', count: 4
    fill_in 'js-user-search-input', with: 'yameo'
    find('#js-user-search-input').send_keys :return
    assert_text '辞目 辞目夫', count: 1

    fill_in 'js-user-search-input', with: 'kimura'
    find('#js-user-search-input').send_keys :return
    assert_text '一致するユーザーはいません'
  end

  test 'search only trainee when target is trainee' do
    visit_with_auth '/users?target=trainee', 'komagata'
    assert_selector '.users-item', count: 3 # 元々2だったが、退会ユーザーがカウントされるようになった影響で+1増えた
    fill_in 'js-user-search-input', with: 'Kensyu Seiko'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kensyu Seiko', count: 1

    fill_in 'js-user-search-input', with: 'kimura'
    find('#js-user-search-input').send_keys :return
    assert_text '一致するユーザーはいません'
  end

  test 'search users from all users when target is all' do
    visit_with_auth '/users?target=all', 'komagata'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'hajime'
    find('#js-user-search-input').send_keys :return
    assert_text 'Hajime Tayo', count: 1

    fill_in 'js-user-search-input', with: 'machida'
    find('#js-user-search-input').send_keys :return
    assert_text 'Machida Teppei', count: 1
  end

  test 'find retired users from all users when target is all' do
    visit_with_auth '/users?target=all', 'komagata'
    fill_in 'js-user-search-input', with: 'yameo'
    find('#js-user-search-input').send_keys :return
    within('.users-item__header-end') do
      assert_text 'yameo'
    end
  end

  test 'find hibernated users from all users when target is all' do
    visit_with_auth '/users?target=all', 'komagata'
    fill_in 'js-user-search-input', with: 'kyuukai'
    find('#js-user-search-input').send_keys :return
    within('.users-item__header-end') do
      assert_text 'kyuukai'
    end
  end

  test "don't show incremental search when target's users aren't exist" do
    user = users(:jobseeking)
    user.update!(career_path: 0)

    visit_with_auth '/users?target=job_seeking', 'komagata'
    assert_no_selector '.users-item'
    assert has_no_field? 'js-user-search-input'

    user.update!(career_path: 1)
  end

  test 'only show incremental search in all tab' do
    visit_with_auth '/users', 'komagata'
    assert_selector '#js-user-search-input'

    visit '/generations'
    assert has_no_field? 'js-user-search-input'

    visit '/users/tags'
    assert has_no_field? 'js-user-search-input'

    visit '/users/tags/猫'
    assert has_no_field? 'js-user-search-input'

    visit '/users?target=followings'
    assert has_no_field? 'js-user-search-input'

    visit '/users/companies'
    assert has_no_field? 'js-user-search-input'
  end

  test 'incremental search needs more than two characters for Japanese and three for others' do
    visit_with_auth '/users', 'komagata'
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'ki'
    find('#js-user-search-input').send_keys :return
    assert_selector '.users-item', count: 24
    fill_in 'js-user-search-input', with: 'kim'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura', count: 2

    fill_in 'js-user-search-input', with: 'キ'
    find('#js-user-search-input').send_keys :return
    assert_selector '.user-list'
    assert_no_selector '.searched-user-list'
    fill_in 'js-user-search-input', with: 'キム'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura', count: 2
  end

  test 'only admin can see link to talk on user list page' do
    visit_with_auth '/users', 'komagata'
    assert_link '相談部屋'
  end

  test 'not admin cannot see link to talk on user list page' do
    visit_with_auth '/users', 'kimura'
    assert_selector '.page-header__title', text: 'ユーザー'
    assert_no_link '相談部屋'
  end

  test 'mentor can see retired and hibernated tabs' do
    visit_with_auth '/users', 'mentormentaro'
    assert_link '休会', href: '/users?target=hibernated'
    assert_link '退会', href: '/users?target=retired'
  end

  test 'admin can see retired and hibernated tabs' do
    visit_with_auth '/users', 'komagata'
    assert_link '休会', href: '/users?target=hibernated'
    assert_link '退会', href: '/users?target=retired'
  end

  test 'user can not see retired and hibernated tabs if the user is not admin or mentor' do
    visit_with_auth '/users', 'sotugyou'
    assert_no_link '休会', href: '/users?target=hibernated'
    assert_no_link '退会', href: '/users?target=retired'
  end

  test "should show students and trainees's active activity counts" do
    visit_with_auth users_path, 'kimura'
    assert_selector '.card-counts__item-value', text: '0'

    click_link('卒業生')
    assert_selector '.card-counts__item-value', text: '0'

    click_link('研修生')
    assert_selector '.card-counts__item-value', text: '0'
  end

  test "should show hibernated user and retired user's activity counts" do
    visit_with_auth users_path, 'komagata'
    click_link('休会')
    assert_selector '.card-counts__item-value', text: '0'

    click_link('退会')
    assert_selector '.card-counts__item-value', text: '0'
  end

  test "should not show mentor and adviser's activity counts" do
    visit_with_auth users_path, 'kimura'
    click_link('メンター')
    assert_no_selector '.card-counts__items'

    click_link('アドバイザー')
    assert_no_selector '.card-counts__items'
  end

  test 'show retirement message on users page' do
    visit_with_auth users_path, 'komagata'
    click_link('退会')
    assert_selector '.users-item__inactive-message-container.is-only-mentor .users-item__inactive-message', text: '退会しました'
  end

  test 'show hibernation elasped days message on users page' do
    travel_to Time.zone.local(2020, 1, 11, 0, 0, 0) do
      visit_with_auth users_path, 'komagata'
      click_link('休会')
      assert_selector '.users-item__inactive-message-container.is-only-mentor .users-item__inactive-message', text: '休会中: 2020年01月01日〜(10日経過)'
    end
  end

  test 'students and trainees filter' do
    visit_with_auth '/users', 'komagata'
    click_link '現役 + 研修生'

    assert_selector('a.tab-nav__item-link.is-active', text: '現役 + 研修生')
    filtered_users = all('.users-item__icon .a-user-role')
    assert(filtered_users.all? do |user|
      classes = user[:class].split(' ')
      classes.include?('is-student') || classes.include?('is-trainee')
    end)
  end

  test 'students filter' do
    visit_with_auth '/users', 'komagata'
    click_link '現役生'

    assert_selector('a.tab-nav__item-link.is-active', text: '現役生')
    filtered_users = all('.users-item__icon .a-user-role')
    assert(filtered_users.all? { |user| user[:class].split(' ').include?('is-student') })
  end
end
