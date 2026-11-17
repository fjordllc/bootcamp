# frozen_string_literal: true

require 'browserless_system_test_case'

class Admin::UsersBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing users' do
    visit_with_auth '/admin/users?target=all', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing users without parameters' do
    visit_with_auth '/admin/users', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing inactive users' do
    visit_with_auth '/admin/users?target=inactive', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing retired users' do
    visit_with_auth '/admin/users?target=retired', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing graduated users' do
    visit_with_auth '/admin/users?target=graduate', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing advisers' do
    visit_with_auth '/admin/users?target=adviser', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing mentors' do
    visit_with_auth '/admin/users?target=mentor', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing trainee' do
    visit_with_auth '/admin/users?target=trainee', 'komagata'
    assert_equal '管理ページ | FBC', title
    assert_text 'kensyu（Kensyu Seiko）'
  end

  test 'filter users by job seeking: true' do
    visit_with_auth '/admin/users?job_seeking=true', 'komagata'
    assert_text 'jobseeker（就活 のぞむ）'
    assert_no_text 'kensyu（Kensyu Seiko）'
  end

  test 'filter users by payment method: card' do
    visit_with_auth '/admin/users?payment_method=card', 'komagata'
    assert_text 'kensyu（Kensyu Seiko）'
    assert_no_text 'kensyu-invoice（請求書払いの研修生）'
  end

  test 'filter users by payment method: invoice' do
    visit_with_auth '/admin/users?payment_method=invoice', 'komagata'
    assert_text 'kensyu-invoice（請求書払いの研修生）'
    assert_no_text 'kensyu（Kensyu Seiko）'
  end

  test 'accessed by non-administrative users' do
    user = users(:hatsuno)
    visit_with_auth edit_admin_user_path(user.id), 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'show training end date if user is trainee' do
    user = users(:kensyu)
    visit_with_auth edit_admin_user_path(user.id), 'komagata'
    assert has_checked_field?('checkbox_trainee', visible: false)
    assert has_field?('user_training_ends_on')
  end

  test 'general user cannot change user course' do
    user = users(:kensyu)
    visit_with_auth "/admin/users/#{user.id}/edit", 'kimura'
    assert_current_path('/')
    assert_text '管理者としてログインしてください'
  end

  test 'administrator can update profiles of mentors' do
    user = users(:machida)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert_text 'プロフィール'
    assert_text 'プロフィール画像'
    assert_text 'プロフィール名'
    assert_text 'プロフィール文'
  end
end
