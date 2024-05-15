# frozen_string_literal: true

require 'application_system_test_case'

class RequestRetirementsTest < ApplicationSystemTestCase
  test 'not logged in user requests retirement' do
    visit new_request_retirement_path
    assert_text '退会申請'

    user = users(:senpai)
    fill_in('申請者のアカウント', with: user.login_name)
    fill_in('メールアドレス', with: user.email)
    fill_in('会社名', with: user.company.name)
    fill_in('退会をさせる方のアカウント', with: 'kensyu')
    fill_in('退会理由', with: '退職してしまったため。')
    choose '削除する', allow_label_click: true
    click_on '申請する'
    page.driver.browser.switch_to.alert.accept

    assert_text '退会申請を受け付けました。'
  end

  test 'logged in user as adviser requests retirement' do
    visit_with_auth new_request_retirement_path, 'senpai'
    visit new_request_retirement_path
    assert_text '退会申請'

    select 'kensyu', from: '退会をさせる方のアカウント'
    fill_in('退会理由', with: '退職してしまったため。')
    choose '削除する', allow_label_click: true
    click_on '申請する'
    page.driver.browser.switch_to.alert.accept

    assert_text '退会申請を受け付けました。'
  end
end
