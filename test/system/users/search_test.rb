# frozen_string_literal: true

require 'application_system_test_case'

class Users::SearchTest < ApplicationSystemTestCase
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
    assert_selector '.users-item', count: 3
    fill_in 'js-user-search-input', with: 'yameo'
    find('#js-user-search-input').send_keys :return
    assert_text '辞目 辞目夫', count: 1

    fill_in 'js-user-search-input', with: 'kimura'
    find('#js-user-search-input').send_keys :return
    assert_text '一致するユーザーはいません'
  end

  test 'search only trainee when target is trainee' do
    visit_with_auth '/users?target=trainee', 'komagata'
    assert_selector '.users-item', count: 3
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

  test 'incremental search works with short search words' do
    visit_with_auth '/users', 'komagata'
    assert_selector '.users-item', count: 24

    # 2文字の英数字検索で絞り込み結果が表示される
    fill_in 'js-user-search-input', with: 'mu'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura', count: 2

    # 3文字の英数字検索でも正常に動作
    fill_in 'js-user-search-input', with: 'kim'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura', count: 2

    # 1文字の日本語検索で絞り込み結果が表示される
    fill_in 'js-user-search-input', with: 'ム'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura', count: 2

    # 2文字の日本語検索でも正常に動作
    fill_in 'js-user-search-input', with: 'キム'
    find('#js-user-search-input').send_keys :return
    assert_text 'Kimura', count: 2
  end
end
