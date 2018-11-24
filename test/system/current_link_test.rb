# frozen_string_literal: true

require "application_system_test_case"

class CurrentLinkTest < ApplicationSystemTestCase
  test "is-activeが適切にcssでクラスに設定されるか確認" do
    login_user "machida", "testtest"

    visit "/users"
    assert_selector "a.global-nav-links__link.is-active[href='/users']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    visit "/users/#{users(:komagata).id}"
    assert_selector "a.global-nav-links__link.is-active[href='/users']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    visit "/courses/#{courses(:course_1).id}/practices"
    assert_selector "a.global-nav-links__link.is-active[href='/courses/#{courses(:course_1).id}/practices']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    visit "/practices/#{practices(:practice_1).id}"
    assert_selector "a.global-nav-links__link.is-active[href='/courses/#{courses(:course_1).id}/practices']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    visit "/practices/#{practices(:practice_1).id}/reports"
    assert_selector "a.global-nav-links__link.is-active[href='/courses/#{courses(:course_1).id}/practices']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    visit "/practices/#{practices(:practice_1).id}/products"
    assert_selector "a.global-nav-links__link.is-active[href='/courses/#{courses(:course_1).id}/practices']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    visit "/questions"
    assert_selector "a.global-nav-links__link.is-active[href='/questions']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    visit "/questions/#{questions(:question_1).id}"
    assert_selector "a.global-nav-links__link.is-active[href='/questions']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    visit "/pages"
    assert_selector "a.global-nav-links__link.is-active[href='/pages']", count: 1
    assert_selector "a.global-nav-links__link.is-active", count: 1

    visit "/admin/users"
    assert_selector "a.page-tabs__item-link.is-active[href='/admin/users']", count: 1
    assert_selector "a.page-tabs__item-link.is-active", count: 1

    visit "/admin/categories"
    assert_selector "a.page-tabs__item-link.is-active[href='/admin/categories']", count: 1
    assert_selector "a.page-tabs__item-link.is-active", count: 1

    visit "/admin"
    assert_selector "a.page-tabs__item-link.is-active[href='/admin']", count: 1
    assert_selector "a.page-tabs__item-link.is-active", count: 1
  end
end
