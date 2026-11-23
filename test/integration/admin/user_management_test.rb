# frozen_string_literal: true

require 'test_helper'

class Admin::UserManagementTest < ActionDispatch::IntegrationTest
  UPDATED = 'ユーザー情報を更新しました。'

  setup do
    login('komagata')
  end

  test 'lists graduated office workers' do
    get '/admin/users?target=graduate&job=office_worker'
    assert_select 'title', text: '管理ページ | FBC'
    assert_includes response.body, 'sotugyou-with-job（卒業 就職済美）'
    assert_not_includes response.body, 'sotugyou（卒業 太郎）'
  end

  test 'excludes hibernated and retired users from year-end-party email list' do
    get '/admin/users?target=year_end_party'
    assert_select 'title', text: '管理ページ | FBC'
    assert_not_includes response.body, users(:kyuukai).email
    assert_not_includes response.body, users(:yameo).email
    assert_includes response.body, users(:kimura).email
  end

  test 'lists advisers except in the list of trial period users' do
    Campaign.create!(start_at: 20.years.ago, end_at: 7.days.from_now, title: 'テスト用キャンペーン', trial_period: 4)

    get '/admin/users?target=campaign'
    assert_response :success
    assert_not_includes css_select('.page-body').text, 'アドバイザー'

    get '/admin/users?target=adviser'
    assert_includes css_select('.page-body').text, 'アドバイザー'
  end

  test 'shows an error when login name is already taken' do
    user = users(:hatsuno)
    patch admin_user_path(user), params: { user: { login_name: 'komagata' } }
    assert_response :success
    assert_includes response.body, 'アカウントはすでに存在します'
    assert_equal 'hatsuno', user.reload.login_name
  end

  test 'updates company of adviser' do
    user = users(:senpai)
    company = Company.find_by!(name: 'Lokka Inc.')
    patch admin_user_path(user), params: { user: { company_id: company.id } }
    assert_updated(user)
    assert_includes css_select('.user-metas__item-value').text, 'Lokka Inc.'
  end

  test 'updates training end date' do
    user = users(:kensyu)
    training_ends_on = Date.current.next_year
    patch admin_user_path(user), params: { user: { training_ends_on: } }
    assert_updated(user)
    assert_equal training_ends_on, user.reload.training_ends_on
  end

  test 'changes course' do
    login('machida')
    user = users(:kensyu)
    course = Course.find_by!(title: 'iOSエンジニア')
    get edit_admin_user_path(user)
    assert_select 'select[name="user[course_id]"] option[value=?]', course.id.to_s, text: 'iOSエンジニア'

    patch admin_user_path(user), params: { user: { course_id: course.id } }
    assert_updated(user)
    assert_equal course, user.reload.course
  end

  test 'does not show profile fields for general users' do
    get edit_admin_user_path(users(:kimura))
    assert_response :success
    assert_not_includes css_select('form[name=user]').text, 'プロフィール'
  end

  test 'shows mentor profile fields after making user a mentor' do
    user = users(:advijirou)
    get edit_admin_user_path(user)
    assert_not_includes response.body, 'メンター紹介用公開プロフィール'

    patch admin_user_path(user), params: { user: { mentor: '1' } }
    assert_updated(user)
    get edit_admin_user_path(user)
    assert_includes response.body, 'メンター紹介用公開プロフィール'
  end

  test 'hides mentor profile' do
    user = users(:mentormentaro)
    get edit_admin_user_path(user)
    assert_select 'input[type=checkbox][name="user[show_mentor_profile]"][checked]'

    patch admin_user_path(user), params: { user: { show_mentor_profile: '0' } }
    assert_updated(user)
    get edit_admin_user_path(user)
    assert_select 'input[type=checkbox][name="user[show_mentor_profile]"]'
    assert_select 'input[type=checkbox][name="user[show_mentor_profile]"][checked]', count: 0
  end

  test 'uploads and deletes diploma file' do
    user = users(:kimura)
    patch admin_user_path(user), params: { user: { diploma_file: diploma('diploma.pdf', 'application/pdf') } }
    assert_updated(user)
    assert user.reload.diploma_file.attached?
    get edit_admin_user_path(user)
    assert_select 'a#js-pdf-file-link', text: /diploma\.pdf/

    patch admin_user_path(user), params: { user: { remove_diploma: '1' } }
    assert_updated(user)
    assert_not user.reload.diploma_file.attached?
    get edit_admin_user_path(user)
    assert_select 'a#js-pdf-file-link', count: 0
  end

  test 'rejects diploma file that is not PDF' do
    user = users(:kimura)
    patch admin_user_path(user), params: { user: { diploma_file: diploma('diploma.html', 'text/html') } }
    assert_response :success
    assert_includes response.body, '卒業証書(PDF)はPDF形式にしてください'
    assert_not user.reload.diploma_file.attached?
  end

  test 'retires user' do
    user = users(:hatsuno)
    user.discord_profile.update!(times_id: '987654321987654321')
    # 退会時に Stripe の API を呼ばないようにする
    user.update_columns(subscription_id: nil, customer_id: nil) # rubocop:disable Rails/SkipsModelValidations
    date = Date.current

    Discord::Server.stub(:delete_text_channel, true) do
      patch admin_user_path(user), params: { user: { retired_on: date } }
    end
    assert_updated(user)
    assert_equal date, user.reload.retired_on
    assert_nil user.discord_profile.reload.times_id
  end

  test 'graduates user and cancels subscription' do
    user = users(:hatsuno)
    date = Date.current
    subscription_url = "https://api.stripe.com/v1/subscriptions/#{user.subscription_id}"
    stub_request(:get, subscription_url)
      .to_return(status: 200, body: { id: user.subscription_id, status: 'active' }.to_json)
    stub_request(:post, subscription_url)
      .to_return(status: 200, body: { id: user.subscription_id, cancel_at_period_end: true }.to_json)

    Card.stub(:destroy_all, true) do
      patch admin_user_path(user), params: { user: { graduated_on: date } }
    end
    assert_updated(user)
    assert_equal date, user.reload.graduated_on
    assert_requested(:post, subscription_url) { |req| req.body.include?('cancel_at_period_end=true') }
  end

  private

  def login(login_name)
    post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
  end

  def diploma(filename, type)
    fixture_file_upload("users/diplomas/#{filename}", type)
  end

  def assert_updated(user)
    assert_redirected_to user_url(user)
    follow_redirect!
    assert_includes response.body, UPDATED
  end
end
