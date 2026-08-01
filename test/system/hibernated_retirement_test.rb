# frozen_string_literal: true

require 'application_system_test_case'

class HibernatedRetirementTest < ApplicationSystemTestCase
  test 'retire as hibernated user' do
    visit new_hibernated_retirement_path
    fill_in 'user[email]', with: 'kyuukai@fjord.jp'
    fill_in 'user[password]', with: 'testtest'
    find('label', text: 'とても良い').click
    Card.stub(:destroy_all, true) do
      VCR.use_cassette 'subscription/update', vcr_options do
        accept_confirm do
          click_on '退会する'
        end
      end
      assert_text '退会処理が完了しました。'
    end
  end

  test 'retire as not hibernated user' do
    visit new_hibernated_retirement_path
    fill_in 'user[email]', with: 'hatsuno@fjord.jp'
    fill_in 'user[password]', with: 'testtest'
    accept_confirm do
      click_on '退会する'
    end
    assert_text '休会していない'
  end

  test 'retire with wrong password' do
    visit new_hibernated_retirement_path
    fill_in 'user[email]', with: 'kyuukai@fjord.jp'
    fill_in 'user[password]', with: 'wrongpass'
    find('label', text: 'とても良い').click
    accept_confirm do
      click_on '退会する'
    end
    assert_text 'メールアドレスかパスワードが違います'
  end
end
