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
      click_button '日報を確認'
    end
    assert has_button? '日報の確認を取り消す'
    visit reports_path
    assert_text '確認済'
  end

  test 'success report checking cancel' do
    visit_with_auth "/reports/#{reports(:report20).id}", 'komagata'
    assert_text '昨日よりできませんでした'
    accept_alert do
      click_button '日報を確認'
    end
    click_button '日報の確認を取り消す'

    assert_button '日報を確認'
    assert_no_css 'stamp__content is-title'
  end

  test 'comment and check report' do
    visit_with_auth "/reports/#{reports(:report20).id}", 'komagata'
    fill_in 'new_comment[description]', with: '日報でcomment+確認OKにするtest'
    click_button '確認OKにする'
    assert_text '確認済'
    assert_text '日報でcomment+確認OKにするtest'
  end

  test 'comment and check report by mentor' do
    visit_with_auth "/reports/#{reports(:report20).id}", 'mentormentaro'
    fill_in 'new_comment[description]', with: '日報でcomment+確認OKにするtest'
    click_button '確認OKにする'
    assert_text '確認済'
    assert_text '日報でcomment+確認OKにするtest'
  end

  test 'display error message when checking confirmed report' do
    using_session :mentormentaro do
      visit_with_auth "/reports/#{reports(:report15).id}", 'mentormentaro'
    end

    using_session :komagata do
      visit_with_auth "/reports/#{reports(:report15).id}", 'komagata'
    end

    using_session :mentormentaro do
      click_button '日報を確認'
      assert_text '確認済'
    end

    using_session :komagata do
      click_button '日報を確認'
      assert_text 'この日報は確認済です'
    end
  end
end
