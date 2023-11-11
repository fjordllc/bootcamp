# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::CoursesTest < ApplicationSystemTestCase
  test 'show listing courses' do
    visit_with_auth '/mentor/courses', 'mentormentaro'
    assert_equal 'メンターページ | FBC', title
  end

  test 'create course' do
    visit_with_auth '/mentor/courses/new', 'mentormentaro'
    within 'form[name=course]' do
      fill_in 'course[title]', with: 'テストコース'
      fill_in 'course[description]', with: 'テストのコースです。'
      click_button '内容を保存'
    end
    assert_text 'コースを作成しました。'
  end

  test 'update course' do
    visit_with_auth "/mentor/courses/#{courses(:course1).id}/edit", 'mentormentaro'
    within 'form[name=course]' do
      fill_in 'course[title]', with: 'テストコース'
      fill_in 'course[description]', with: 'テストのコースです。'
      click_button '内容を保存'
    end
    assert_text 'コースを更新しました。'
  end
end
