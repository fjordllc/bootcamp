# frozen_string_literal: true

require 'application_system_test_case'

class SignUpTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @bot_token = Discord::Server.authorize_token
    Discord::Server.authorize_token = nil
    Capybara.reset_sessions!
  rescue Net::ReadTimeout
    # セッションリセット時のタイムアウトは無視して続行
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
    Discord::Server.authorize_token = @bot_token
  end

  test 'sign up' do
    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: 'test@example.com'
      fill_in 'user[name]', with: 'テスト 太郎'
      fill_in 'user[name_kana]', with: 'テスト タロウ'
      fill_in 'user[password]', with: 'testtest'
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
      find('label', text: '検索エンジン').click
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 50', '111')

    VCR.use_cassette 'sign_up/valid-card', record: :once, match_requests_on: %i[method uri] do
      click_button '参加する'
      assert_text '参加登録が完了しました'
    end
    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:signed_up], text: 'fooさんが新しく入会しました！')
  end

  test 'student signs up without profile and is asked for it on dashboard' do
    # VCR のカセットに記録したメールアドレスに合わせる
    email = 'taguo@example.com'

    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'taguo'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト 後子'
      fill_in 'user[name_kana]', with: 'テスト アトコ'
      fill_in 'user[password]', with: 'testtest'
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
      find('label', text: '検索エンジン').click
    end

    fill_stripe_element('5555 5555 5555 4444', '12 / 50', '111')

    VCR.use_cassette 'sign_up/profile_later', record: :once, match_requests_on: %i[method uri] do
      click_button '参加する'
      assert_text '参加登録が完了しました'
    end

    user = User.find_by(email:)
    assert_nil user.description
    visit_with_auth '/', 'taguo'
    assert_link '自己紹介を登録してください。'
    assert_link '職業を登録してください。'
    assert_link '学習に使うマシン・OSを登録してください。'
  end

  test 'signup form helps with login name, kana and password before submit' do
    visit '/users/new'
    within 'form[name=user]' do
      hint = '[data-login-name-input-target="message"]'
      fill_in 'user[login_name]', with: 'ab'
      assert_selector hint, text: 'あと1文字以上入力してください。'
      fill_in 'user[login_name]', with: 'ab_c'
      assert_selector hint, text: '半角英数字と-（ハイフン）のみが使用できます。'
      fill_in 'user[login_name]', with: 'abc'
      assert_no_selector hint

      fill_in 'user[name_kana]', with: 'てすと たろう'
      find_field('user[name]').click
      assert_field 'user[name_kana]', with: 'テスト タロウ'

      fill_in 'user[password]', with: 'testtest'
      assert_selector "input[name='user[password]'][type='password']"
      click_button '表示'
      assert_selector "input[name='user[password]'][type='text']"
      assert_no_field 'user[password_confirmation]'
    end
  end
end
