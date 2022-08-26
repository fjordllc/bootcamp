# frozen_string_literal: true

require 'application_system_test_case'

class User::CompaniesTest < ApplicationSystemTestCase
  test 'show companies with users' do
    visit_with_auth '/users/companies', 'komagata'
    assert_equal '企業別ユーザー一覧 | FBC', title
    assert_text companies(:company1).name
    assert_no_text companies(:company3).name
  end

  test 'show all users belonging to each company' do
    visit_with_auth '/users/companies', 'kimura'

    assert_selector('a.tab-nav__item-link.is-active', text: '全員')
    assert_text '企業別ユーザー一覧（全員）'
    assert_selector('.group-company-name__label', text: 'Fjord Inc.')
    within first('.a-user-icons__items') do
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-admin')['data-login-name'], 'komagata'
      assert_equal all('.a-user-icons__item-icon.a-user-icon.is-admin')[1]['data-login-name'], 'machida'
    end
    assert_selector('.group-company-name__label', text: 'root inc.')
    within all('.a-user-icons__items')[1] do
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-trainee')['data-login-name'], 'kensyu'
      assert_equal all('.a-user-icons__item-icon.a-user-icon.is-trainee')[1]['data-login-name'], 'kensyuowata'
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-adviser')['data-login-name'], 'senpai'
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-graduate')['data-login-name'], 'sotsugyoukigyoshozoku'
    end

    click_link '全員'

    assert_text '企業別ユーザー一覧（全員）'
    assert_selector('.group-company-name__label', text: 'Fjord Inc.')
    within first('.a-user-icons__items') do
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-admin')['data-login-name'], 'komagata'
      assert_equal all('.a-user-icons__item-icon.a-user-icon.is-admin')[1]['data-login-name'], 'machida'
    end
    assert_selector('.group-company-name__label', text: 'root inc.')
    within all('.a-user-icons__items')[1] do
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-trainee')['data-login-name'], 'kensyu'
      assert_equal all('.a-user-icons__item-icon.a-user-icon.is-trainee')[1]['data-login-name'], 'kensyuowata'
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-adviser')['data-login-name'], 'senpai'
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-graduate')['data-login-name'], 'sotsugyoukigyoshozoku'
    end
  end

  test 'show trainee belonging to each company' do
    visit_with_auth '/users/companies', 'kimura'
    click_link '研修生'

    assert_text '企業別ユーザー一覧（研修生）'
    assert_selector('a.tab-nav__item-link.is-active', text: '研修生')
    assert_no_selector('.group-company-name__label', text: 'Fjord Inc.')
    assert_selector('.group-company-name__label', text: 'root inc.')
    assert_equal first('.a-user-icons__item-icon.a-user-icon.is-trainee')['data-login-name'], 'kensyu'
    assert_equal all('.a-user-icons__item-icon.a-user-icon.is-trainee')[1]['data-login-name'], 'kensyuowata'
  end

  test 'show adviser belonging to each company' do
    visit_with_auth '/users/companies', 'kimura'
    click_link 'アドバイザー'

    assert_text '企業別ユーザー一覧（アドバイザー）'
    assert_selector('a.tab-nav__item-link.is-active', text: 'アドバイザー')
    assert_no_selector('.group-company-name__label', text: 'Fjord Inc.')
    assert_selector('.group-company-name__label', text: 'root inc.')
    assert_equal first('.a-user-icons__item-icon.a-user-icon.is-adviser')['data-login-name'], 'senpai'
  end

  test 'show graduate belonging to each company' do
    visit_with_auth '/users/companies', 'kimura'
    click_link '卒業生'

    assert_text '企業別ユーザー一覧（卒業生）'
    assert_selector('a.tab-nav__item-link.is-active', text: '卒業生')
    assert_no_selector('.group-company-name__label', text: 'Fjord Inc.')
    assert_selector('.group-company-name__label', text: 'root inc.')
    assert_equal first('.a-user-icons__item-icon.a-user-icon.is-graduate')['data-login-name'], 'sotsugyoukigyoshozoku'
  end

  test 'show mentor belonging to each company' do
    visit_with_auth '/users/companies', 'kimura'
    click_link 'メンター'

    assert_text '企業別ユーザー一覧（メンター）'
    assert_selector('a.tab-nav__item-link.is-active', text: 'メンター')
    assert_selector('.group-company-name__label', text: 'Fjord Inc.')
    assert_equal first('.a-user-icons__item-icon.a-user-icon.is-admin')['data-login-name'], 'komagata'
    assert_equal all('.a-user-icons__item-icon.a-user-icon.is-admin')[1]['data-login-name'], 'machida'
    assert_no_selector('.group-company-name__label', text: 'root inc.')
  end
end
