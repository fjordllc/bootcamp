# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUserTest < ApplicationSystemTestCase
  test 'update user' do
    visit_with_auth '/current_user/edit', 'komagata'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'testuser'
      find('label', text: 'VSCode').click
      click_on '更新する'
    end

    assert_text 'ユーザー情報を更新しました。'
  end

  test 'update user with blank' do
    visit_with_auth '/current_user/edit', 'komagata'
    fill_in 'user[description]', with: ''
    find('label[for=other_editor]').click
    fill_in 'other_input', with: ''
    click_on '更新する'

    assert_text '自己紹介を入力してください'
    assert_text 'その他のエディタを入力してください'
  end

  test 'update times url with wrong url' do
    visit_with_auth '/current_user/edit', 'komagata'
    fill_in 'user[discord_profile_attributes][times_url]', with: 'https://example.com/channels/1234/5678/'
    click_button '更新する'
    assert_text '分報URLは https://discord.com/channels/ で始まる Discord のチャンネル URL を入力してください。'
  end

  test 'do not show after graduation hope when advisor or mentor' do
    visit_with_auth '/current_user/edit', 'hajime'
    assert_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを教えてください'
    visit_with_auth '/current_user/edit', 'senpai'
    assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを教えてください'
    visit_with_auth '/current_user/edit', 'mentormentaro'
    assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを教えてください'
  end

  test 'should not show training end date if user is not trainee' do
    visit_with_auth edit_current_user_path, 'kimura'
    assert has_no_field?('user_training_ends_on')
  end

  test 'show training end date if user is trainee' do
    visit_with_auth edit_current_user_path, 'kensyu'
    assert has_field?('user_training_ends_on')
  end

  test 'update value of training end date' do
    training_ends_on = Date.current.next_year
    visit_with_auth edit_current_user_path, 'kensyu'
    fill_in 'user_training_ends_on', with: training_ends_on
    click_on '更新する'
    visit_with_auth edit_current_user_path, 'kensyu'
    assert has_field?('user_training_ends_on', with: training_ends_on)
  end

  test 'mentors advisors graduates admin can register their companies' do
    visit_with_auth '/current_user/edit', 'mentormentaro'
    assert_text '企業'
    within '.choices__inner' do
      assert_text '所属なし'
    end

    visit_with_auth '/current_user/edit', 'advijirou'
    assert_text '企業'
    within '.choices__inner' do
      assert_text '所属なし'
    end

    visit_with_auth '/current_user/edit', 'sotugyou'
    assert_text '企業'
    within '.choices__inner' do
      assert_text '所属なし'
    end

    visit_with_auth '/current_user/edit', 'komagata'
    assert_text '企業'
    within '.choices__inner' do
      assert_text 'Lokka Inc.'
    end
  end

  test 'not mentors advisors graduates admin can not register their companies' do
    visit_with_auth '/current_user/edit', 'kimura'
    assert_no_text '所属なし'
  end

  test 'update os' do
    kimura = users(:kimura)
    visit_with_auth '/current_user/edit', 'kimura'
    first('label', text: 'Linux').click

    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'

    visit_with_auth "/users/#{kimura.id}", 'komagata'
    assert_text 'Linux'
  end

  test 'update admin user\'s retired_on' do
    user = users(:komagata)

    visit_with_auth '/current_user/edit', 'komagata'
    check '退会済', allow_label_click: true
    fill_in 'user[retired_on]', with: '2022-05-01'.to_date

    click_on '更新する'

    visit_with_auth '/current_user/edit', 'komagata'

    assert_match user.reload.retired_on.to_s, '2022-05-01'
  end

  test 'update admin user\'s graduated_on' do
    user = users(:komagata)

    visit_with_auth '/current_user/edit', 'komagata'
    check '卒業', allow_label_click: true
    fill_in 'user[graduated_on]', with: '2022-05-01'.to_date
    click_on '更新する'

    assert_match user.reload.graduated_on.to_s, '2022-05-01'
  end

  test 'update admin user\'s github_collaborator' do
    user = users(:komagata)

    visit_with_auth '/current_user/edit', 'komagata'
    uncheck 'GitHubチーム', allow_label_click: true

    click_on '更新する'

    assert_not user.reload.github_collaborator
  end

  test 'general users cannot update their profiles' do
    visit_with_auth '/current_user/edit', 'kimura'
    assert_no_text 'プロフィール'
    assert_no_text 'プロフィール画像'
    assert_no_text 'プロフィール名'
    assert_no_text 'プロフィール文'
  end

  test 'mentors can update their profiles' do
    visit_with_auth '/current_user/edit', 'komagata'
    assert_text 'プロフィール'
    assert_text 'プロフィール画像'
    assert_text 'プロフィール名'
    assert_text 'プロフィール文'
  end

  test 'display country and subdivision select box' do
    visit_with_auth '/current_user/edit', 'komagata'
    assert has_checked_field? 'register_address_no', visible: false
    assert_not has_css? '#country-form'
    assert_not has_css? '#subdivision-form'

    find('label[for=register_address_yes]').click
    assert has_css? '#country-form'
    assert_select 'user[country_code]', selected: '日本'
    assert has_css? '#subdivision-form'
    within('#subdivision-select') do
      assert_text '北海道'
    end
  end

  test 'do not register country and subdivision' do
    user = users(:kimura)
    assert_equal 'JP', user.country_code
    assert_equal '13', user.subdivision_code

    visit_with_auth '/current_user/edit', 'kimura'
    assert has_checked_field? 'register_address_yes', visible: false

    find('label[for=register_address_no]').click
    click_on '更新する'

    assert_equal '', user.reload.country_code
    assert_equal '', user.reload.subdivision_code
  end

  test 'change subdivisions' do
    visit_with_auth '/current_user/edit', 'kimura'
    within('#subdivision-select') do
      assert_text '北海道'
    end

    select '米国', from: 'user[country_code]'

    within('#subdivision-select') do
      assert_text 'アラスカ州'
    end
  end

  test 'register editor with text box' do
    visit_with_auth '/current_user/edit', 'kimura'
    find('label[for=other_editor]').click
    fill_in 'other_input', with: 'textbringer'
    click_on '更新する'

    assert_text 'textbringer'
  end

  test 'update admin user\'s auto_retire' do
    visit_with_auth '/current_user/edit', 'komagata'
    check '休会三ヶ月後に自動退会しない', allow_label_click: true
    click_on '更新する'

    assert_not users(:komagata).reload.auto_retire
  end

  test 'update admin user\'s mentor' do
    visit_with_auth '/current_user/edit', 'komagata'
    uncheck 'メンター', allow_label_click: true
    click_on '更新する'

    assert_not users(:komagata).reload.mentor
  end

  test 'update admin user\'s subscription_id' do
    visit_with_auth '/current_user/edit', 'komagata'
    fill_in 'サブスクリプションID', with: 'sub_987654321'
    click_on '更新する'

    assert_match users(:komagata).reload.subscription_id, 'sub_987654321'
  end

  test 'change experiences' do
    kensyu = users(:kensyu)

    visit_with_auth "/users/#{kensyu.id}", 'komagata'
    assert_text 'Rubyの経験あり'

    visit_with_auth '/current_user/edit', 'kensyu'
    uncheck 'Rubyの経験あり', allow_label_click: true
    check 'JavaScriptの経験あり', allow_label_click: true
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'

    visit_with_auth "/users/#{kensyu.id}", 'komagata'
    assert_no_text 'Rubyの経験あり'
    assert_text 'JavaScriptの経験あり'
  end

  test 'visible learning time frames table for non advisors and grad users' do
    visit_with_auth '/current_user/edit', 'kimura'
    assert_selector 'h1.auth-form__title', text: '登録情報変更'
    assert_selector 'label.a-form-label', text: '主な活動予定時間'

    visit_with_auth '/current_user/edit', 'mentormentaro'
    assert_selector 'h1.auth-form__title', text: '登録情報変更'
    assert_selector 'label.a-form-label', text: '主な活動予定時間'

    visit_with_auth '/current_user/edit', 'kensyu'
    assert_selector 'h1.auth-form__title', text: '登録情報変更'
    assert_selector 'label.a-form-label', text: '主な活動予定時間'

    visit_with_auth '/current_user/edit', 'advijirou'
    assert_selector 'h1.auth-form__title', text: '登録情報変更'
    assert_no_selector 'label.a-form-label', text: '主な活動予定時間'

    visit_with_auth '/current_user/edit', 'sotugyou'
    assert_selector 'h1.auth-form__title', text: '登録情報変更'
    assert_no_selector 'label.a-form-label', text: '主な活動予定時間'
  end

  test 'profile updates after setting activity time' do
    visit_with_auth '/current_user/edit', 'kimura'
    assert_selector 'h1.auth-form__title', text: '登録情報変更'
    assert_selector 'label.a-form-label', text: '主な活動予定時間'

    find('label[for="user_learning_time_frame_ids_1"]').click
    find('label[for="user_learning_time_frame_ids_25"]').click
    find('label[for="user_learning_time_frame_ids_49"]').click

    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'

    assert_selector 'h1.page-main-header__title', text: 'プロフィール'
    assert_selector 'h2.card-header__title', text: '主な活動予定時間'

    assert page.has_selector?('td[name="checked_1"]')
    assert page.has_selector?('td[name="checked_25"]')
    assert page.has_selector?('td[name="checked_49"]')
  end
end
