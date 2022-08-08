# frozen_string_literal: true

require 'application_system_test_case'

class ComebackTest < ApplicationSystemTestCase
  test 'come back as hibernated user' do
    visit new_comeback_path
    within('form[name=comeback]') do
      fill_in 'user[email]', with: 'kyuukai@fjord.jp'
      fill_in 'user[password]', with: 'testtest'
    end

    VCR.use_cassette 'subscription/create', vcr_options do
      click_on '休会から復帰する'
      assert_text '休会から復帰しました'
    end
  end

  test 'come back as active user' do
    visit new_comeback_path
    within('form[name=comeback]') do
      fill_in 'user[email]', with: 'hatsuno@fjord.jp'
      fill_in 'user[password]', with: 'testtest'
      click_on '休会から復帰する'
    end
    assert_text '休会していないユーザーです'
  end

  test 'come back with wrong password' do
    visit new_comeback_path
    within('form[name=comeback]') do
      fill_in 'user[email]', with: 'kyuukai@fjord.jp'
      fill_in 'user[password]', with: 'wrongpass'
      click_on '休会から復帰する'
    end
    assert_text 'メールアドレスかパスワードが違います'
  end
end
