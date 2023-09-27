# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::Courses::CategoriesTest < ApplicationSystemTestCase
  test 'sorting categories of a course' do
    visit_with_auth course_practices_path(courses(:course1)), 'kimura'
    assert_equal all('h2.categories-item__title')[0].text, categories(:category2).name
    assert_equal all('h2.categories-item__title')[1].text, categories(:category4).name

    visit_with_auth mentor_course_categories_path(courses(:course1)), 'komagata'
    source = all('.js-grab')[1] # category2
    target = all('.js-grab')[3] # category4
    source.drag_to(target)

    visit_with_auth course_practices_path(courses(:course1)), 'kimura'
    assert_equal all('h2.categories-item__title')[0].text, categories(:category4).name
    assert_equal all('h2.categories-item__title')[1].text, categories(:category2).name
  end

  test 'sorting categories of a course not affecting the categories order of another course' do
    visit_with_auth course_practices_path(courses(:course3)), 'kimura'
    assert_equal all('h2.categories-item__title')[0].text, categories(:category13).name
    assert_equal all('h2.categories-item__title')[1].text, categories(:category15).name

    visit_with_auth mentor_course_categories_path(courses(:course1)), 'komagata'
    source = all('.js-grab')[12] # category13
    target = all('.js-grab')[14] # category15
    source.drag_to(target)

    visit_with_auth course_practices_path(courses(:course3)), 'kimura'
    assert_equal all('h2.categories-item__title')[0].text, categories(:category13).name
    assert_equal all('h2.categories-item__title')[1].text, categories(:category15).name
  end
end
