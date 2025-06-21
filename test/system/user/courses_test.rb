# frozen_string_literal: true

require 'application_system_test_case'

class User::CoursesTest < ApplicationSystemTestCase
  test 'show users index by course' do
    visit_with_auth '/users/courses', 'komagata'
    assert_equal 'コース別ユーザー一覧 | FBC', title
    assert_selector 'h2.page-header__title', text: 'ユーザー一覧'
  end

  test 'show users sorted by rails course' do
    visit_with_auth '/users/courses', 'kimura'
    assert_selector('a.tab-nav__item-link.is-active', text: 'Rails')
    assert_text 'Railsエンジニアコース（31）'
    assert_selector '.users-item', count: 24
    assert_link 'kimuramitai'
    assert_text 'Kimura Mitai'
    assert_no_link 'front-end-course'
    assert_no_text 'フロントエンドエンジニアコースのユーザー'
  end

  test 'show users sorted by front end course' do
    visit_with_auth '/users/courses?target=front_end_course', 'kimura'
    assert_selector('a.tab-nav__item-link.is-active', text: 'フロントエンド')
    assert_text 'フロントエンドエンジニアコース（1）'
    assert_selector '.users-item', count: 1
    assert_link 'front-end-course'
    assert_text 'フロントエンドエンジニアコースのユーザー'
    assert_no_link 'kimuramitai'
    assert_no_text 'Kimura Mitai'
  end

  test 'show users sorted by other courses' do
    visit_with_auth '/users/courses?target=other_courses', 'kimura'
    assert_selector('a.tab-nav__item-link.is-active', text: 'その他')
    assert_text 'その他のコース（2）'
    assert_selector '.users-item', count: 2
    assert_link 'unity-course'
    assert_text 'Unityゲームエンジニアコースのユーザー'
    assert_link 'ios-course'
    assert_text 'iOSエンジニアコースのユーザー'
  end
end
