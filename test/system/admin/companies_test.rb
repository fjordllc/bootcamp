# frozen_string_literal: true

require 'application_system_test_case'

class Admin::CompaniesTest < ApplicationSystemTestCase
  test 'show listing companies' do
    visit_with_auth '/admin/companies', 'komagata'
    assert_equal '企業一覧 | FBC', title
    assert has_link?(companies(:newest_company).name, href: company_path(companies(:newest_company)))
  end

  test 'create company' do
    visit_with_auth '/admin/companies/new', 'komagata'
    within 'form[name=company]' do
      fill_in 'company[name]', with: 'テスト企業'
      fill_in 'company[description]', with: 'テストの企業です。'
      fill_in 'company[website]', with: 'https://example.com'
      fill_in 'company[blog_url]', with: 'https://example.com'
      fill_in 'company[memo]', with: '管理者のみが閲覧できるメモです。'
      click_button '登録する'
    end
    assert_text '企業を作成しました。'

    visit_with_auth company_path(Company.last), 'komagata'
    assert_text '管理者のみが閲覧できるメモです。'
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
    first('.pagination__item-link', text: '2').click
    assert_equal 2, page.all('.pagination__item-link.is-active', text: '2').count
    first('.pagination__item-link', text: '1').click
    assert_equal 2, page.all('.pagination__item-link.is-active', text: '1').count
  end

  test 'no pagination when 20 companies or less exist' do
    Company.where.not(description: 'このデータはページャーの確認用').destroy_all
    visit_with_auth '/admin/companies', 'komagata'
    assert_no_selector 'nav.pagination'
  end

  test 'companies are ordered by created_at desc' do
    visit_with_auth '/admin/companies', 'komagata'
    within all('.admin-table__item')[0] do
      assert_selector 'td.company-name', text: '【created_at降順確認】一番新しい株式会社'
    end

    within all('.admin-table__item')[1] do
      assert_selector 'td.company-name', text: '【created_at降順確認】二番目に新しい株式会社'
    end

    all('.pagination__item.is-next a.pagination__item-link.is-next')[0].click

    within all('.admin-table__item').last do
      assert_selector 'td.company-name', text: '【created_at降順確認】最古株式会社'
    end
  end

  test 'admin memo is not visible to non-admin users' do
    visit_with_auth company_path(companies(:company1)), 'mentormentaro'
    assert_no_text '管理者向け企業メモ'
  end

  test 'adviser edits own company and cannot edit others' do
    own_company = companies(:company1)
    other_company = companies(:company2)

    # アドバイザーが自分の企業を設定
    visit_with_auth '/current_user/edit', 'advijirou'
    find('.choices__inner').click
    find('.choices__item--choice', text: own_company.name).click
    click_button '更新する'
    assert_text 'ユーザー情報を更新しました'

    # 自分の企業を編集できる
    visit company_path(own_company)
    assert_text 'アドバイザーとして編集'
    click_link 'アドバイザーとして編集'
    within 'form[name=company]' do
      fill_in 'company[description]', with: '更新しました。'
    end
    click_button '更新する'
    assert_text '企業を更新しました'

    # 他の企業は編集できない
    visit company_path(other_company)
    assert_no_text 'アドバイザーとして編集'
  end

  test 'mentor cannot edit as admin' do
    company = companies(:company1)

    # メンターが自分の企業を設定
    visit_with_auth '/current_user/edit', 'mentormentaro'
    find('.choices__inner').click
    find('.choices__item--choice', text: company.name).click
    click_button '更新する'
    assert_text 'ユーザー情報を更新しました'

    # メンターは管理者として編集できない
    visit company_path(company)
    assert_no_text '管理者として編集'
  end
end
