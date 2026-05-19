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
    move_category_to(source, target)

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
    move_category_to(source, target)

    visit_with_auth course_practices_path(courses(:course3)), 'kimura'
    assert_equal all('h2.categories-item__title')[0].text, categories(:category13).name
    assert_equal all('h2.categories-item__title')[1].text, categories(:category15).name
  end

  private

  def move_category_to(source, target)
    page.evaluate_async_script(<<~JS, source, target)
      const done = arguments[arguments.length - 1]
      const source = arguments[0].closest('[data-courses_category_id]')
      const target = arguments[1].closest('[data-courses_category_id]')
      const items = [...document.querySelectorAll('[data-courses_category_id]')]

      fetch(`/api/courses_categories/${source.dataset.courses_category_id}/position.json`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ insert_at: items.indexOf(target) + 1 })
      }).then(() => done())
    JS
  end
end
