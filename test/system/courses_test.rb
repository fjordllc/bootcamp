# frozen_string_literal: true

require 'application_system_test_case'

class CoursesTest < ApplicationSystemTestCase
  test 'show listing courses' do
    visit_with_auth '/courses', 'mentormentaro'
    assert_equal 'コース一覧 | FBC', title
  end

  test 'create course' do
    visit_with_auth '/mentor/courses/new', 'komagata'
    within 'form[name=course]' do
      fill_in 'course[title]', with: 'テストコース'
      fill_in 'course[description]', with: 'テストのコースです。'
      click_button '内容を保存'
    end
    assert_text 'コースを作成しました。'
  end

  test 'update course' do
    visit_with_auth "/mentor/courses/#{courses(:course1).id}/edit", 'komagata'
    within 'form[name=course]' do
      fill_in 'course[title]', with: 'テストコース'
      find(:css, '#checkbox-published-course').set(true)
      fill_in 'course[description]', with: 'テストのコースです。'
      click_button '内容を保存'
    end
    assert_text 'コースを更新しました。'
  end

  test 'show published courses' do
    visit_with_auth '/courses', 'hajime'
    assert_no_text courses(:course1).title
    visit_with_auth "/mentor/courses/#{courses(:course1).id}/edit", 'komagata'
    within 'form[name=course]' do
      find(:css, '#checkbox-published-course').set(true)
      click_button '内容を保存'
    end
    visit_with_auth '/courses', 'hajime'
    assert_text courses(:course1).title
  end

  test 'mentors can see closed courses' do
    visit_with_auth "/mentor/courses/#{courses(:course1).id}/edit", 'komagata'
    within 'form[name=course]' do
      assert_not find(:css, '#checkbox-published-course').checked?
    end
    visit_with_auth '/courses', 'mentormentaro'
    assert_text courses(:course1).title
  end
end
