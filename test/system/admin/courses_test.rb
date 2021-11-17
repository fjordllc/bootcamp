# frozen_string_literal: true

require 'application_system_test_case'

class Admin::CoursesTest < ApplicationSystemTestCase
  test 'show listing courses' do
    visit_with_auth '/admin/courses', 'komagata'
    assert_equal '管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'create course' do
    visit_with_auth '/admin/courses/new', 'komagata'
    within 'form[name=course]' do
      fill_in 'course[title]', with: 'テストコース'
      fill_in 'course[description]', with: 'テストのコースです。'
      click_button '内容を保存'
    end
    assert_text 'コースを作成しました。'
  end

  test 'update course' do
    visit_with_auth "/admin/courses/#{courses(:course1).id}/edit", 'komagata'
    within 'form[name=course]' do
      fill_in 'course[title]', with: 'テストコース'
      fill_in 'course[description]', with: 'テストのコースです。'
      click_button '内容を保存'
    end
    assert_text 'コースを更新しました。'
  end

  test 'delete course' do
    visit_with_auth '/admin/courses', 'komagata'
    accept_confirm do
      find("#course_#{courses(:course3).id} .js-delete").click
    end
    assert_text 'コースを削除しました。'
  end
end
