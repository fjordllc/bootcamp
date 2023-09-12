# frozen_string_literal: true

require 'application_system_test_case'

class Categories::PracticesTest < ApplicationSystemTestCase
  test 'admin user can access practices sort page' do
    visit_with_auth category_practices_path(categories(:category2)), 'komagata'
    within first('.admin-table__item-value.is-text-align-center.is-grab') do
      assert_selector '.js-grab'
    end
  end

  test 'non-admin user cannot access practices sort page' do
    visit_with_auth category_practices_path(categories(:category2)), 'kimura'
    assert_text '管理者・メンターとしてログインしてください'
  end

  test 'sorting practices of a category' do
    visit_with_auth course_practices_path(courses(:course1)), 'kimura'
    assert_equal all('span.category-practices-item__title-link-label')[0].text, practices(:practice1).title
    assert_equal all('span.category-practices-item__title-link-label')[1].text, practices(:practice3).title

    visit_with_auth category_practices_path(categories(:category2)), 'komagata'
    source = all('.js-grab')[0] # practice1
    target = all('.js-grab')[2] # practice3
    source.drag_to(target)

    visit_with_auth course_practices_path(courses(:course1)), 'kimura'
    assert_equal all('span.category-practices-item__title-link-label')[0].text, practices(:practice3).title
    assert_equal all('span.category-practices-item__title-link-label')[1].text, practices(:practice1).title
  end

  test 'sorting practices of a category not affecting the practices order of another category' do
    visit_with_auth course_practices_path(courses(:course1)), 'kimura'
    assert_equal all('span.category-practices-item__title-link-label')[0].text, practices(:practice1).title
    assert_equal all('span.category-practices-item__title-link-label')[1].text, practices(:practice3).title

    visit_with_auth category_practices_path(categories(:category4)), 'komagata'
    source = all('.js-grab')[0] # practice1
    target = all('.js-grab')[2] # practice3
    source.drag_to(target)

    visit_with_auth course_practices_path(courses(:course1)), 'kimura'
    assert_equal all('span.category-practices-item__title-link-label')[0].text, practices(:practice1).title
    assert_equal all('span.category-practices-item__title-link-label')[1].text, practices(:practice3).title
  end
end
