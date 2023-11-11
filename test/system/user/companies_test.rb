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
    assert_text '企業別（全員）'
    assert_selector('.group-company-name__label', text: 'ユーザの企業に登録しないで株式会社')
    within first('.a-user-icons__items') do
      assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'advisernocolleguetrainee'
    end
    assert_selector('.group-company-name__label', text: 'Fjord inc.')
    within all('.a-user-icons__items')[1] do
      within first('.a-user-role.is-trainee') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'kensyu'
      end
      within first('.a-user-role.is-retired') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'kensyuowata'
      end
      within first('.a-user-role.is-adviser') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'senpai'
      end
      within first('.a-user-role.is-graduate') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'sotsugyoukigyoshozoku'
      end
    end
    assert_selector('.group-company-name__label', text: 'Lokka Inc.')
    within all('.a-user-icons__items')[2] do
      within first('.a-user-role.is-admin') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'komagata'
      end
      within all('.a-user-role.is-admin')[1] do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'machida'
      end
    end

    click_link '全員'

    assert_text '企業別（全員）'
    assert_selector('.group-company-name__label', text: 'ユーザの企業に登録しないで株式会社')
    within first('.a-user-icons__items') do
      within first('.a-user-role.is-adviser') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'advisernocolleguetrainee'
      end
    end
    assert_selector('.group-company-name__label', text: 'Fjord inc.')
    within all('.a-user-icons__items')[1] do
      within first('.a-user-role.is-trainee') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'kensyu'
      end
      within first('.a-user-role.is-retired') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'kensyuowata'
      end
      within first('.a-user-role.is-adviser') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'senpai'
      end
      within first('.a-user-role.is-graduate') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'sotsugyoukigyoshozoku'
      end
    end
    assert_selector('.group-company-name__label', text: 'Lokka Inc.')
    within all('.a-user-icons__items')[2] do
      within first('.a-user-role.is-admin') do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'komagata'
      end
      within all('.a-user-role.is-admin')[1] do
        assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'machida'
      end
    end
  end

  test 'show trainee belonging to each company' do
    visit_with_auth '/users/companies', 'kimura'
    click_link '研修生'

    assert_text '企業別（研修生）'
    assert_selector('a.tab-nav__item-link.is-active', text: '研修生')
    assert_no_selector('.group-company-name__label', text: 'Lokka Inc.')
    assert_selector('.group-company-name__label', text: 'Fjord inc.')
    within first('.a-user-role.is-trainee') do
      assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'kensyu'
    end
    within first('.a-user-role.is-retired') do
      assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'kensyuowata'
    end
  end

  test 'show adviser belonging to each company' do
    visit_with_auth '/users/companies', 'kimura'
    click_link 'アドバイザー'

    assert_text '企業別（アドバイザー）'
    assert_selector('a.tab-nav__item-link.is-active', text: 'アドバイザー')
    assert_no_selector('.group-company-name__label', text: 'Lokka Inc.')
    assert_selector('.group-company-name__label', text: 'ユーザの企業に登録しないで株式会社')
    within first('.a-user-role.is-adviser') do
      assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'advisernocolleguetrainee'
    end
    assert_selector('.group-company-name__label', text: 'Fjord inc.')
    within all('.a-user-role.is-adviser')[1] do
      assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'senpai'
    end
  end

  test 'show graduate belonging to each company' do
    visit_with_auth '/users/companies', 'kimura'
    click_link '卒業生'

    assert_text '企業別（卒業生）'
    assert_selector('a.tab-nav__item-link.is-active', text: '卒業生')
    assert_no_selector('.group-company-name__label', text: 'Lokka Inc.')
    assert_selector('.group-company-name__label', text: 'Fjord inc.')
    within first('.a-user-role.is-graduate') do
      assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'sotsugyoukigyoshozoku'
    end
  end

  test 'show mentor belonging to each company' do
    visit_with_auth '/users/companies', 'kimura'
    click_link 'メンター'

    assert_text '企業別（メンター）'
    assert_selector('a.tab-nav__item-link.is-active', text: 'メンター')
    assert_selector('.group-company-name__label', text: 'Lokka Inc.')
    within first('.a-user-role.is-admin') do
      assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'komagata'
    end
    within all('.a-user-role.is-admin')[1] do
      assert_equal first('.a-user-icons__item-icon.a-user-icon')['data-login-name'], 'machida'
    end
    assert_no_selector('.group-company-name__label', text: 'Fjord inc.')
  end
end
