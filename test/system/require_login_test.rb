# frozen_string_literal: true

require 'application_system_test_case'

class RequireLoginTest < ApplicationSystemTestCase
  setup { @user_id = users(:hatsuno).id }

  test 'show listing user\'s comments' do
    visit "/users/#{@user_id}/comments"
    assert_text 'ログインしてください'
  end

  test 'show listing user\'s products' do
    visit "/users/#{@user_id}/products"
    assert_text 'ログインしてください'
  end

  test 'show listing user\'s reports' do
    visit "/users/#{@user_id}/reports"
    assert_text 'ログインしてください'
  end

  test 'users_path' do
    visit '/users'
    assert_text 'ログインしてください'
  end

  test 'questions_path' do
    visit '/questions'
    assert_equal '/', current_path
    assert_text 'ログインしてください'
  end

  test 'practices_path' do
    visit "/courses/#{courses(:course1).id}/practices"
    assert_text 'ログインしてください'
  end

  test 'reports_path' do
    visit '/reports'
    assert_text 'ログインしてください'
  end

  test 'pages_path' do
    visit '/pages'
    assert_text 'ログインしてください'
  end

  test 'announcements_path' do
    visit '/announcements'
    assert_text 'ログインしてください'
  end

  test 'books_path' do
    visit '/books'
    assert_text 'ログインしてください'
  end

  test 'company_products_path' do
    company = companies(:company1)
    visit "/companies/#{company.id}/products"
    assert_text 'ログインしてください'
  end

  test 'company_reports_path' do
    company = companies(:company1)
    visit "/companies/#{company.id}/reports"
    assert_text 'ログインしてください'
  end

  test 'company_users_path' do
    company = companies(:company1)
    visit "/companies/#{company.id}/users"
    assert_text 'ログインしてください'
  end

  test 'companies_path' do
    visit '/companies'
    assert_text 'ログインしてください'
  end

  test 'course_practices_path' do
    course = courses(:course1)
    visit "/courses/#{course.id}/practices"
    assert_text 'ログインしてください'
  end

  test 'courses_path' do
    visit '/courses'
    assert_text 'ログインしてください'
  end

  test 'current_user_bookmarks_path' do
    visit '/current_user/bookmarks'
    assert_text 'ログインしてください'
  end

  test 'edit_current_user_password_path' do
    visit '/current_user/password/edit'
    assert_text 'ログインしてください'
  end

  test 'current_user_products_path' do
    visit '/current_user/products'
    assert_text 'ログインしてください'
  end

  test 'current_user_reports_path' do
    visit '/current_user/reports'
    assert_text 'ログインしてください'
  end

  test 'edit_current_user_path' do
    visit '/current_user/edit'
    assert_text 'ログインしてください'
  end
end
