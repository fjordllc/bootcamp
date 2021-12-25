# frozen_string_literal: true

require 'application_system_test_case'

class Check::ReportsTest < ApplicationSystemTestCase
  test 'non admin user is non botton' do
    visit_with_auth "/reports/#{reports(:report2).id}", 'kimura'
    assert_not has_button? '日報を確認'
  end

  test 'user can see stamp' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'kimura'
    assert_text '確認済'
  end

  test 'success report checking' do
    visit_with_auth "/reports/#{reports(:report20).id}", 'komagata'
    assert has_button? '日報を確認'
    accept_alert do
      wait_for_vuejs
      click_button '日報を確認'
    end
    assert has_button? '日報の確認を取り消す'
    visit reports_path
    assert_text '確認済'
  end

  test 'success report checking cancel' do
    visit_with_auth "/reports/#{reports(:report20).id}", 'komagata'
    accept_alert do
      wait_for_vuejs
      click_button '日報を確認'
    end
    click_button '日報の確認を取り消す'
    within('.thread') do
      assert_no_text '確認済'
    end
    assert has_button? '日報を確認'
  end

  test 'comment and check report' do
    visit_with_auth "/reports/#{reports(:report20).id}", 'komagata'
    fill_in 'new_comment[description]', with: '日報でcomment+確認OKにするtest'
    accept_alert do
      wait_for_vuejs
      click_button '確認OKにする'
    end
    assert_text '確認済'
    assert_text '日報でcomment+確認OKにするtest'
  end

  test 'success recent report checking' do
    visit_with_auth "/reports/#{reports(:report20).id}", 'komagata'
    accept_alert do
      wait_for_vuejs
      click_button '日報を確認'
    end
    assert page.first('.recent-reports-item').has_css?('.stamp-approve')
  end

  test 'success recent report checking cancel' do
    visit_with_auth "/reports/#{reports(:report20).id}", 'komagata'
    accept_alert do
      wait_for_vuejs
      click_button '日報を確認'
    end
    wait_for_vuejs
    click_button '日報の確認を取り消す'
    assert page.first('.recent-reports-item').has_no_css?('.stamp-approve')
  end
end
