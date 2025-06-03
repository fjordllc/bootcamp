# frozen_string_literal: true

require 'application_system_test_case'

class Talk::SearchFunctionalityTest < ApplicationSystemTestCase
  test 'incremental search by login_name' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimuramitai'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by name' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'Kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'Kimura Mitai'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by name_kana' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'キムラ'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'キムラ ミタイ'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by twitter_account' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimuratwitter'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by facebook_url' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimurafacebook'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by blog_url' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimurablog.org'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by github_account' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimuragithub'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by discord_account' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: 'kimuradiscord'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search by description' do
    visit_with_auth '/talks', 'komagata'
    assert_text 'さんの相談部屋', count: 20
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2
    fill_in 'js-talk-search-input', with: '木村さんに似ているとよく言われます。'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1
  end

  test 'incremental search for student_or_trainee' do
    users(:kimuramitai).update!(mentor: true)
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2

    visit '/talks?target=student_and_trainee'
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1 # users(:kimura)
  end

  test 'incremental search for mentor' do
    users(:kimuramitai).update!(login_name: 'mentorkimura')
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'mentor'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 3

    visit '/talks?target=mentor'
    fill_in 'js-talk-search-input', with: 'mentor'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2 # users(:mentormentaro) users(:'long-id-mentor')
  end

  test 'incremental search for graduated' do
    users(:kimuramitai).update!(login_name: 'sotugyoukimura')
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'sotugyou'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 3

    visit '/talks?target=graduate'
    fill_in 'js-talk-search-input', with: 'sotugyou'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2 # users(:sotugyou, :sotugyou_with_job)
  end

  test 'incremental search for adviser' do
    users(:kimuramitai).update!(login_name: 'advikimura')
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'advi'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 3

    visit '/talks?target=adviser'
    fill_in 'js-talk-search-input', with: 'advi'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2 # users(:advijirou)
  end

  test 'incremental search for trainee' do
    users(:kimuramitai).update!(login_name: 'kensyukimura')
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'kensyu'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 4

    visit '/talks?target=trainee'
    fill_in 'js-talk-search-input', with: 'kensyu'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 3 # users(:nocompanykensyu, :kensyu, :kensyuowata)
  end

  test 'incremental search for retired' do
    users(:kimuramitai).update!(login_name: 'yameokimura')
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'yameo'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2

    visit '/talks?target=retired'
    fill_in 'js-talk-search-input', with: 'yameo'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1 # users(:yameo)
  end

  test 'incremental search for action uncompleted' do
    users(:kimura).talk.update!(action_completed: false)
    visit_with_auth '/talks', 'komagata'
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 2

    visit '/talks/action_uncompleted'
    fill_in 'js-talk-search-input', with: 'kimura'
    find('#js-talk-search-input').send_keys :return
    assert_text 'さんの相談部屋', count: 1 # users(:kimura)
  end

  test 'switch between normal list and searched list' do
    visit_with_auth '/talks', 'komagata'
    assert_selector '.talk-list'
    assert_no_selector '.searched-talk-list'

    # /^[\w-]+$/ の場合は3文字以上、それ以外は2文字以上で検索結果を表示
    fill_in 'js-talk-search-input', with: 'kim'
    find('#js-talk-search-input').send_keys :return
    assert_no_selector '.talk-list'
    assert_selector '.searched-talk-list'

    fill_in 'js-talk-search-input', with: 'ki'
    find('#js-talk-search-input').send_keys :return
    assert_selector '.talk-list'
    assert_no_selector '.searched-talk-list'

    fill_in 'js-talk-search-input', with: 'キム'
    find('#js-talk-search-input').send_keys :return
    assert_no_selector '.talk-list'
    assert_selector '.searched-talk-list'

    fill_in 'js-talk-search-input', with: 'キ'
    find('#js-talk-search-input').send_keys :return
    assert_selector '.talk-list'
    assert_no_selector '.searched-talk-list'
  end

  test 'show no talks message when no talks found' do
    visit_with_auth '/talks', 'komagata'

    fill_in 'js-talk-search-input', with: 'hoge'
    find('#js-talk-search-input').send_keys :return
    assert_text '一致する相談部屋はありません'
  end
end
