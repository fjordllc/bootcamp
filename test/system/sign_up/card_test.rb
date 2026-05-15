# frozen_string_literal: true

require 'application_system_test_case'

module SignUp
  class CardTest < ApplicationSystemTestCase
    setup do
      @bot_token = Discord::Server.authorize_token
      Discord::Server.authorize_token = nil
      Capybara.reset_sessions!
    rescue Net::ReadTimeout
      # セッションリセット時のタイムアウトは無視して続行
    end

    teardown do
      Discord::Server.authorize_token = @bot_token
    end

    test 'sign up with expired card' do
      visit '/users/new'
      within 'form[name=user]' do
        fill_in 'user[login_name]', with: 'foo'
        fill_in 'user[email]', with: 'jiro@example.com'
        fill_in 'user[name]', with: 'テスト 次郎'
        fill_in 'user[name_kana]', with: 'テスト ジロウ'
        fill_in 'user[description]', with: 'テスト次郎です。'
        fill_in 'user[password]', with: 'testtest'
        fill_in 'user[password_confirmation]', with: 'testtest'
        select '学生', from: 'user[job]'
        find('label', text: 'Mac（Intel チップ）').click
        check 'Rubyの経験あり', allow_label_click: true
        find('label', text: 'アンチハラスメントポリシーに同意').click
        find('label', text: '利用規約に同意').click
        find('label', text: '検索エンジン').click
      end

      fill_stripe_element('4000 0000 0000 0069', '12 / 50', '111')

      VCR.use_cassette 'sign_up/expired-card', vcr_options do
        click_button '参加する'
        assert_text 'クレジットカードが有効期限切れです。'
      end
    end

    test 'sign up with incorrect cvc card' do
      visit '/users/new'
      within 'form[name=user]' do
        fill_in 'user[login_name]', with: 'foo'
        fill_in 'user[email]', with: 'saburo@example.com'
        fill_in 'user[name]', with: 'テスト 三郎'
        fill_in 'user[name_kana]', with: 'テスト サブロウ'
        fill_in 'user[description]', with: 'テスト三郎です。'
        fill_in 'user[password]', with: 'testtest'
        fill_in 'user[password_confirmation]', with: 'testtest'
        select '学生', from: 'user[job]'
        find('label', text: 'Mac（Intel チップ）').click
        check 'Rubyの経験あり', allow_label_click: true
        find('label', text: 'アンチハラスメントポリシーに同意').click
        find('label', text: '利用規約に同意').click
        find('label', text: '検索エンジン').click
      end

      fill_stripe_element('4000 0000 0000 0127', '12 / 50', '111')

      VCR.use_cassette 'sign_up/incorrect-cvc-card', vcr_options do
        click_button '参加する'
        assert_text 'クレジットカードセキュリティコードが正しくありません。'
      end
    end

    test 'sign up with declined card' do
      visit '/users/new'
      within 'form[name=user]' do
        fill_in 'user[login_name]', with: 'foo'
        fill_in 'user[email]', with: 'hanako@example.com'
        fill_in 'user[name]', with: 'テスト 花子'
        fill_in 'user[name_kana]', with: 'テスト ハナコ'
        fill_in 'user[description]', with: 'テスト花子です。'
        fill_in 'user[password]', with: 'testtest'
        fill_in 'user[password_confirmation]', with: 'testtest'
        select '学生', from: 'user[job]'
        find('label', text: 'Mac（Intel チップ）').click
        check 'Rubyの経験あり', allow_label_click: true
        find('label', text: 'アンチハラスメントポリシーに同意').click
        find('label', text: '利用規約に同意').click
        find('label', text: '検索エンジン').click
      end

      fill_stripe_element('4000 0000 0000 0002', '12 / 50', '111')

      VCR.use_cassette 'sign_up/declined-card', vcr_options do
        click_button '参加する'
        assert_text 'クレジットカードへの請求が拒否されました。'
      end
    end
  end
end
