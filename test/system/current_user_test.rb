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

  test 'update os' do
    kimura = users(:kimura)
    visit_with_auth '/current_user/edit', 'kimura'
    first('label', text: 'Linux').click

    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'

    visit_with_auth "/users/#{kimura.id}", 'komagata'
    assert_text 'Linux'
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
