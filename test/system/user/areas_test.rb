# frozen_string_literal: true

require 'application_system_test_case'

class User::AreasTest < ApplicationSystemTestCase
  test 'show side menu' do
    visit_with_auth '/users/areas', 'kimura'
    within '.page-body__column.is-sub' do
      assert_selector 'nav.page-nav.a-card', count: 3
      assert_selector 'h2.page-nav__title', text: '関東地方'
      assert_selector 'a.page-nav__item-link', text: '東京都（3）'
      assert_selector 'a.page-nav__item-link', text: '栃木県（1）'
      assert_selector 'h2.page-nav__title', text: '九州・沖縄地方'
      assert_selector 'a.page-nav__item-link', text: '長崎県（1）'
      assert_selector 'h2.page-nav__title', text: '海外'
      assert_selector 'a.page-nav__item-link', text: '米国（2）'
      assert_selector 'a.page-nav__item-link', text: 'カナダ（1）'

      click_on '東京都（3）'
    end

    assert_selector 'h1.page-main-header__title', text: '東京都'
    within '.page-body__column.is-sub' do
      assert_selector '.a-card', count: 3
    end
  end

  test 'show areas' do
    visit_with_auth '/users/areas', 'kimura'
    assert_selector 'h1.page-main-header__title', text: '都道府県別'
    within '.page-body__column.is-main' do
      assert_selector '.user-group', count: 5
      assert_selector 'h2.user-group__title', text: '東京都'
      assert_selector 'h2.user-group__title', text: '米国'
      assert_selector 'h2.user-group__title', text: '栃木県'
      assert_selector 'h2.user-group__title', text: 'カナダ'
      assert_selector 'h2.user-group__title', text: '長崎県'

      click_on '東京都'
    end

    assert_selector 'h1.page-main-header__title', text: '東京都'
  end

  test 'show user icons in area card' do
    visit_with_auth '/users/areas', 'kimura'
    within first('.user-group') do
      assert_selector 'img.a-user-icon', count: 3
      assert_selector 'img.a-user-icon[data-login-name="kimura"]'
      assert_selector 'img.a-user-icon[data-login-name="adminonly"]'
      assert_selector 'img.a-user-icon[data-login-name="machida"]'
    end
  end

  test 'show users by area' do
    visit_with_auth users_area_path(area: '東京都'), 'kimura'
    assert_selector 'h1.page-main-header__title', text: '東京都'
    within '.page-body__column.is-main' do
      assert_selector '.users-item', count: 3
      assert_selector 'a.card-list-item-title__title', text: 'kimura'
      assert_selector 'a.card-list-item-title__title', text: 'adminonly'
      assert_selector 'a.card-list-item-title__title', text: 'machida'
    end
  end

  test 'show message when visit area with no one' do
    visit_with_auth users_area_path(area: '茨城県'), 'kimura'
    assert_selector 'h1.page-main-header__title', text: '茨城県'
    assert_text 'まだユーザーはいません'
  end
end
