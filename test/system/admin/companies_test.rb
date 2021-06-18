# frozen_string_literal: true

require 'application_system_test_case'

class Admin::CompaniesTest < ApplicationSystemTestCase
  setup { login_user 'komagata', 'testtest' }

  test 'show listing companies' do
    visit '/admin/companies'
    assert_equal '企業 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'create company' do
    visit '/admin/companies/new'
    within 'form[name=company]' do
      fill_in 'company[name]', with: 'テスト企業'
      fill_in 'company[description]', with: 'テストの企業です。'
      fill_in 'company[website]', with: 'https://example.com'
      click_button '登録する'
    end
    assert_text '企業を作成しました。'
  end

  test 'update company' do
    visit "/admin/companies/#{companies(:company1).id}/edit"
    within 'form[name=company]' do
      fill_in 'company[name]', with: 'テスト企業'
      fill_in 'company[description]', with: 'テストの企業です。'
      fill_in 'company[website]', with: 'https://example.com'
      click_button '更新する'
    end
    assert_text '企業を更新しました。'
  end

  test 'delete company' do
    visit '/admin/companies'
    accept_confirm do
      find("#company_#{companies(:company1).id} .js-delete").click
    end
    assert_text '企業を削除しました。'
  end

  test 'show pagination' do
    login_user 'komagata', 'testtest'
    26.times do
      Company.create(name: 'test', description: 'test', website: 'test')
    end
    visit '/admin/companies'
    assert_selector 'nav.pagination', count: 2
  end
end
