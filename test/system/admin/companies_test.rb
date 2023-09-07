# frozen_string_literal: true

require 'application_system_test_case'

class Admin::CompaniesTest < ApplicationSystemTestCase
  test 'show listing companies' do
    visit_with_auth '/admin/companies', 'komagata'
    assert_equal '管理ページ | FBC', title
    assert has_link?(companies(:company1).name, href: company_path(companies(:company1)))
  end

  test 'create company' do
    visit_with_auth '/admin/companies/new', 'komagata'
    within 'form[name=company]' do
      fill_in 'company[name]', with: 'テスト企業'
      fill_in 'company[description]', with: 'テストの企業です。'
      fill_in 'company[website]', with: 'https://example.com'
      fill_in 'company[blog_url]', with: 'https://example.com'
      click_button '登録する'
    end
    assert_text '企業を作成しました。'
  end

  test 'update company' do
    visit_with_auth "/admin/companies/#{companies(:company1).id}/edit", 'komagata'
    within 'form[name=company]' do
      fill_in 'company[name]', with: 'テスト企業'
      fill_in 'company[description]', with: 'テストの企業です。'
      fill_in 'company[website]', with: 'https://example.com'
      fill_in 'company[blog_url]', with: 'https://example.com'
      click_button '更新する'
    end
    assert_text '企業を更新しました。'
  end

  test 'delete company' do
    visit_with_auth "/admin/companies/#{companies(:company1).id}/edit", 'komagata'
    click_on '削除'
    page.driver.browser.switch_to.alert.accept
    assert_text '企業を削除しました。'
  end

  test 'show pagination' do
    visit_with_auth '/admin/companies', 'komagata'
    assert_selector 'nav.pagination', count: 2
  end

  test 'no pagination when 20 companies or less exist' do
    (21..27).each do |n|
      Company.find(id: companies("company#{n}".to_sym).id).destroy
    end
    visit_with_auth '/admin/companies', 'komagata'
    assert_no_selector 'nav.pagination'
  end

  test 'no pagination when 1 company exists' do
    (2..20).each do |n|
      Company.find(id: companies("company#{n}".to_sym).id).destroy
    end
    visit_with_auth '/admin/companies', 'komagata'
    assert_no_selector 'nav.pagination'
  end
end
