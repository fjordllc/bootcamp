# frozen_string_literal: true

require 'application_system_test_case'

class Course::PracticesTest < ApplicationSystemTestCase
  test 'show/hide the progress of others' do
    visit_with_auth practice_path(practices(:practice1)), 'hatsuno'
    click_button '着手'
    assert_selector '.js-started.is-active'
    visit course_practices_path(courses(:course1).id)

    assert page.find(:css, '#display-progress', visible: false).checked?
    assert_not has_selector?('.is-hidden-users')
    user_path = user_path(users(:hatsuno).id)
    within page.find('.page-body__column.is-main') do
      assert page.has_link?(href: user_path)
    end

    page.find('#checkbox-progress').click
    assert_not page.find(:css, '#display-progress', visible: false).checked?
    assert has_selector?('.is-hidden-users')
    within page.find('.page-body__column.is-main') do
      assert page.has_no_link?(href: user_path)
    end
  end

  test 'difficulty icon is displayed for all users' do
    visit_with_auth course_practices_path(courses(:course1).id), 'kimura'
    assert_selector '.card-list-item-meta__item .a-meta__label', text: '難易度'
    logout
    visit_with_auth course_practices_path(courses(:course1).id), 'komagata'
    assert_selector '.card-list-item-meta__item .a-meta__label', text: '難易度'
    logout
    visit_with_auth course_practices_path(courses(:course1).id), 'mentormentaro'
    assert_selector '.card-list-item-meta__item .a-meta__label', text: '難易度'
  end

  test 'learning time is displayed only for admin and mentor' do
    visit_with_auth course_practices_path(courses(:course1).id), 'kimura'
    assert_no_selector '.card-list-item-meta__item.is-only-mentor .a-meta__label', text: '所要時間の目安'
    logout
    visit_with_auth course_practices_path(courses(:course1).id), 'komagata'
    assert_selector '.card-list-item-meta__item.is-only-mentor .a-meta__label', text: '所要時間の目安'
    logout
    visit_with_auth course_practices_path(courses(:course1).id), 'mentormentaro'
    assert_selector '.card-list-item-meta__item.is-only-mentor .a-meta__label', text: '所要時間の目安'
  end
end
