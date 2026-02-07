# frozen_string_literal: true

require 'application_system_test_case'

module SignUp
  class ValidationTest < ApplicationSystemTestCase
    setup do
      @bot_token = Discord::Server.authorize_token
      Discord::Server.authorize_token = nil
      Capybara.reset_sessions!
    rescue Net::ReadTimeout
      page.driver.quit
    end

    teardown do
      Discord::Server.authorize_token = @bot_token
    end

    test 'sign up with reserved login name' do
      visit '/users/new'
      within 'form[name=user]' do
        fill_in 'user[login_name]', with: 'mentor'
        fill_in 'user[email]', with: 'akiko@example.com'
        fill_in 'user[name]', with: 'テスト 秋子'
        fill_in 'user[name_kana]', with: 'テスト アキコ'
        fill_in 'user[description]', with: 'テスト秋子です。'
        fill_in 'user[password]', with: 'testtest'
        fill_in 'user[password_confirmation]', with: 'testtest'
        select '学生', from: 'user[job]'
        find('label', text: 'Mac（Intel チップ）').click
        check 'Rubyの経験あり', allow_label_click: true
        find('label', text: 'アンチハラスメントポリシーに同意').click
        find('label', text: '利用規約に同意').click
      end

      fill_stripe_element('4242 4242 4242 4242', '12 / 50', '111')

      VCR.use_cassette 'sign_up/valid-card', record: :once do
        click_button '参加する'
        assert_text 'に使用できない文字列が含まれています'
      end
    end

    test 'sign up with empty description ' do
      visit '/users/new'
      within 'form[name=user]' do
        fill_in 'user[login_name]', with: 'foo'
        fill_in 'user[email]', with: 'siro@example.com'
        fill_in 'user[name]', with: 'テスト 四郎'
        fill_in 'user[name_kana]', with: 'テスト シロウ'
        fill_in 'user[password]', with: 'testtest'
        fill_in 'user[password_confirmation]', with: 'testtest'
        select '学生', from: 'user[job]'
        find('label', text: 'Mac（Intel チップ）').click
        check 'Rubyの経験あり', allow_label_click: true
        find('label', text: 'アンチハラスメントポリシーに同意').click
        find('label', text: '利用規約に同意').click
      end

      fill_stripe_element('5555 5555 5555 4444', '12 / 50', '111')

      VCR.use_cassette 'sign_up/valid-card', record: :once do
        click_button '参加する'
        assert_text '自己紹介を入力してください'
      end
    end

    test 'hidden input learning time frames table' do
      visit '/users/new'
      assert_no_selector ".form-item.a-form-label[for='user_learning_time_frames']", text: '主な活動予定時間'
    end
  end
end
