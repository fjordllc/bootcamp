# frozen_string_literal: true

require 'application_system_test_case'

module SignUp
  class RoleTest < ApplicationSystemTestCase
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

    test 'sign up as adviser' do
      visit '/users/new?role=adviser'

      email = 'haruko@example.com'

      within 'form[name=user]' do
        fill_in 'user[login_name]', with: 'foo'
        fill_in 'user[email]', with: email
        fill_in 'user[name]', with: 'テスト 春子'
        fill_in 'user[name_kana]', with: 'テスト ハルコ'
        fill_in 'user[description]', with: 'テスト春子です。'
        fill_in 'user[password]', with: 'testtest'
        fill_in 'user[password_confirmation]', with: 'testtest'
        find('label', text: 'アンチハラスメントポリシーに同意').click
        find('label', text: '利用規約に同意').click
      end

      click_button 'アドバイザー登録'
      assert_text 'アドバイザー登録が完了しました'
      assert User.find_by(email:).adviser?
    end

    test 'sign up as mentor' do
      visit '/users/new?role=mentor'

      email = 'shunka@example.com'

      within 'form[name=user]' do
        fill_in 'user[login_name]', with: 'shunka'
        fill_in 'user[email]', with: email
        fill_in 'user[name]', with: 'テスト 春夏'
        fill_in 'user[name_kana]', with: 'テスト シュンカ'
        fill_in 'user[description]', with: 'テスト春夏です。'
        fill_in 'user[password]', with: 'testtest'
        fill_in 'user[password_confirmation]', with: 'testtest'
        find('label', text: 'Mac（Intel チップ）').click
        first('.choices__inner').click
        find('.choices__list--dropdown').click
        find('.choices__list').click
        find('label', text: 'アンチハラスメントポリシーに同意').click
        find('label', text: '利用規約に同意').click
      end

      click_button 'メンター登録'
      assert_text 'メンター登録が完了しました'
      assert User.find_by(email:).mentor?
    end

    test 'sign up as adviser with company_id' do
      visit "/users/new?role=adviser&company_id=#{companies(:company2).id}"

      email = 'fuyuko@example.com'

      within 'form[name=user]' do
        fill_in 'user[login_name]', with: 'foo'
        fill_in 'user[email]', with: email
        fill_in 'user[name]', with: 'テスト ふゆこ'
        fill_in 'user[name_kana]', with: 'テスト フユコ'
        fill_in 'user[description]', with: 'テストふゆこです。'
        fill_in 'user[password]', with: 'testtest'
        fill_in 'user[password_confirmation]', with: 'testtest'
        find('label', text: 'アンチハラスメントポリシーに同意').click
        find('label', text: '利用規約に同意').click
      end

      click_button 'アドバイザー登録'
      assert_text 'アドバイザー登録が完了しました'
      assert_equal User.find_by(email:).company_id, companies(:company2).id
    end

    test 'job seeker option is hidden for adviser' do
      visit '/users/new?role=adviser'
      assert_selector 'form[name=user]'
      assert has_no_selector? "input[name='user[job_seeker]']", visible: :all
    end
  end
end
