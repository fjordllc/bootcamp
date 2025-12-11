# frozen_string_literal: true

require 'application_system_test_case'

class SignUpTest < ApplicationSystemTestCase
  setup do
    @bot_token = Discord::Server.authorize_token
    Discord::Server.authorize_token = nil
    Capybara.reset_sessions!
  end

  teardown do
    Discord::Server.authorize_token = @bot_token
  end

  test 'sign up' do
    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: 'test@example.com'
      fill_in 'user[name]', with: 'テスト 太郎'
      fill_in 'user[name_kana]', with: 'テスト タロウ'
      fill_in 'user[description]', with: 'テスト太郎です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      fill_in 'user[after_graduation_hope]', with: '起業したいです'
      select '学生', from: 'user[job]'
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
      find('label', text: '検索エンジン').click
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 50', '111')

    VCR.use_cassette 'sign_up/valid-card', record: :once, match_requests_on: %i[method uri] do
      click_button '参加する'
      assert_text '参加登録が完了しました'
    end
  end

  test 'job seeker option is shown for student' do
    visit '/users/new'
    assert_selector 'form[name=user]'
    assert_selector "input[name='user[job_seeker]']", visible: :all
  end

  test 'sign up with tag' do
    email = 'taguo@example.com'
    tag = 'タグ夫'

    visit '/users/new'

    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'taguo'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト タグ夫'
      fill_in 'user[name_kana]', with: 'テスト タグオ'
      fill_in 'user[description]', with: 'タグ登録確認用'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click

      # Try to find tagify input, fallback to hidden input if not available
      if has_selector?('.tagify__input')
        tag_input = find('.tagify__input')
        tag_input.set tag
        tag_input.native.send_keys :return
      elsif has_selector?('input[name="user[tag_list]"]', visible: :hidden)
        page.execute_script("document.querySelector('input[name=\"user[tag_list]\"]').value = '#{tag}'")
      end
    end

    fill_stripe_element('5555 5555 5555 4444', '12 / 50', '111')

    VCR.use_cassette 'sign_up/tag', record: :once, match_requests_on: %i[method uri] do
      click_button '参加する'
      assert_text '参加登録が完了しました'
      user = User.find_by(email:)
      visit_with_auth user_path(user), 'taguo'
      assert_text 'タグ夫'
    end
  end
end
