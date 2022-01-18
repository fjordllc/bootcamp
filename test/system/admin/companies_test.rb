# frozen_string_literal: true

require 'application_system_test_case'

class Admin::CompaniesTest < ApplicationSystemTestCase
  test 'show listing companies' do
    visit_with_auth '/admin/companies', 'komagata'
    assert_equal '管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
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

  test 'show pagination' do
    26.times do
      Company.create(name: 'test', description: 'test', website: 'test')
    end
    visit_with_auth '/admin/companies', 'komagata'
    assert_selector 'nav.pagination', count: 2
  end

  test 'delete company' do
    visit_with_auth '/admin/companies', 'komagata'
    wait_for_vuejs
    accept_confirm do
      find("#company_#{companies(:company2).id} a.a-button.is-sm.is-danger.is-icon.js-delete").click
    end
    assert_no_text companies(:company2).name
  end
end
