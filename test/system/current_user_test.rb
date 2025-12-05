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
    assert_text 'ユーザー情報を更新しました。'
    visit_with_auth edit_current_user_path, 'kensyu'
    assert_field 'user_training_ends_on', with: training_ends_on.to_s
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

  test 'register editor with text box' do
    visit_with_auth '/current_user/edit', 'kimura'
    find('label[for=other_editor]').click
    fill_in 'other_input', with: 'textbringer'
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'

    assert_text 'textbringer'
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

end
