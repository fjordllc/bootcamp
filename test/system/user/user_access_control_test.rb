# frozen_string_literal: true

require 'application_system_test_case'

class UserAccessControlTest < ApplicationSystemTestCase
  test 'access by other users' do
    user = users(:hatsuno)
    visit_with_auth edit_admin_user_path(user.id), 'mentormentaro'
    assert_text '管理者としてログインしてください'
  end

  test "normal user can't see unchecked number table" do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'hatsuno'
    assert_equal 0, all('.admin-table').length
  end

  test 'show inactive users only to mentors' do
    User.inactive_students_and_trainees.each do |user|
      user.update_columns(last_activity_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    end

    visit_with_auth '/', 'komagata'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    assert_no_text '1ヶ月以上ログインのないユーザー'

    users(:kimura).update!(
      last_activity_at: Time.zone.local(2020, 1, 1, 0, 0, 0)
    )

    visit_with_auth '/', 'komagata'
    assert_text '1ヶ月以上ログインのないユーザー'

    visit_with_auth '/', 'hatsuno'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    assert_no_text '1ヶ月以上ログインのないユーザー'
  end

  test 'student access control' do
    visit_with_auth '/users', 'kimura'
    assert_selector '.page-header__title', text: 'ユーザー'
    assert_no_text '全員'
    assert_no_text '就職活動中'

    visit 'users?target=retired'
    assert_selector '.page-header__title', text: 'ユーザー'
    assert_no_text '退会'
  end

  test 'advisor access control' do
    visit_with_auth '/users', 'advijirou'
    assert_no_text '全員'
    assert find_link('就職活動中')

    visit 'users?target=retired'
    assert_selector '.page-header__title', text: 'ユーザー'
    assert_no_text '退会'
  end

  test 'mentor access control' do
    visit_with_auth '/users', 'mentormentaro'
    assert find_link('就職活動中')
    assert find_link('全員')
  end

  test 'admin access control' do
    visit_with_auth '/users', 'komagata'
    assert find_link('就職活動中')
    assert find_link('退会')
    assert find_link('全員')
  end
end
