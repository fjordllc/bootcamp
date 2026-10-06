# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'anonymous users can view the public landing page' do
    get root_path

    assert_response :success
    assert_select 'body.welcome-home'
    assert_not_includes response.body, '最新のみんなの日報'
  end

  test 'active trainees can view the dashboard' do
    sign_in users(:kensyu)

    get root_path

    assert_response :success
    assert_includes response.body, '最新のみんなの日報'
  end

  test 'training completion rejects an existing session at the root' do
    user = users(:kensyu)
    sign_in user
    assert_equal user.id.to_s, session[:user_id]
    user.update!(training_completed_at: Time.current)

    get root_path

    assert_inactive_session_rejected('研修終了したユーザーです。')
  end

  test 'retirement rejects an existing session at the root' do
    user = users(:hajime)
    sign_in user
    assert_equal user.id.to_s, session[:user_id]
    user.update!(retired_on: Date.current)

    get root_path

    assert_inactive_session_rejected('退会したユーザーです。')
  end

  test 'hibernation rejects an existing session at the root' do
    user = users(:hajime)
    sign_in user
    assert_equal user.id.to_s, session[:user_id]
    user.update!(hibernated_at: Time.current)

    get root_path

    link = '<a target="_blank" rel="noopener" href="/comeback/new">休会復帰ページ</a>'
    assert_inactive_session_rejected("休会中です。#{link}から手続きをお願いします。")
  end

  test 'training completion and pricing stay public with an existing completed session' do
    user = users(:kensyu)
    sign_in user
    user.update!(training_completed_at: Time.current)

    get training_completion_path

    assert_response :success
    assert_equal user.id.to_s, session[:user_id]

    get pricing_path

    assert_response :success
    assert_equal user.id.to_s, session[:user_id]
  end

  test 'anonymous users can view training completion and pricing' do
    get training_completion_path
    assert_response :success

    get pricing_path
    assert_response :success
  end

  test 'student dashboard does not prepare mentor assignments' do
    sign_in users(:hajime)
    Product.stub(:require_assignment_products, -> { flunk 'unused mentor assignments queried' }) do
      get root_path
    end
    assert_response :success
    assert_select '.dashboard-contents.is-mentor', count: 0
    assert_includes response.body, '最新のみんなの日報'
  end

  test 'admin without mentor follows student dashboard' do
    sign_in users(:adminonly)
    Product.stub(:require_assignment_products, -> { flunk 'unused mentor assignments queried' }) do
      get root_path
    end
    assert_response :success
    assert_select '.dashboard-contents.is-mentor', count: 0
    assert_includes response.body, '最新のみんなの日報'
  end

  test 'adviser dashboard does not prepare mentor assignments even with mentor flag' do
    user = users(:advijirou)
    [false, true].each do |mentor|
      user.update!(mentor:)
      sign_in user
      Product.stub(:require_assignment_products, -> { flunk 'unused mentor assignments queried' }) do
        get root_path
      end
      assert_response :success
      assert_select '.dashboard-contents.is-adviser'
      assert_select '.dashboard-contents.is-mentor', count: 0
    end
  end

  test 'mentor keeps assignment groups and job seeking card counts including drafts' do
    users(:kimura).update!(career_path: User.career_paths[:job_seeking])
    sign_in users(:mentormentaro)
    get root_path
    assert_response :success
    assert_select '.dashboard-contents.is-mentor'
    assert_select '#elapsed-6days .card-header__title', text: /6日以上経過.*（7）/
    assert_select '#elapsed-5days .card-header__title', text: /5日経過.*（1）/
    assert_select '#elapsed-4days .card-header__title', text: /4日経過.*（1）/
    assert_job_seeking_counts(users(:kimura))
  end

  test 'adviser job seeking cards hide zero links and preserve nonzero counts' do
    users(:kimura).update!(career_path: User.career_paths[:job_seeking])
    empty_user = users(:hajime)
    empty_user.update!(career_path: User.career_paths[:job_seeking])
    empty_user.reports.destroy_all
    empty_user.products.delete_all
    empty_user.works.delete_all
    sign_in users(:advijirou)
    get root_path
    assert_response :success
    assert_job_seeking_counts(users(:kimura))
    assert_select '.card-list-item', text: /#{empty_user.login_name}/ do
      assert_select 'a', text: /日報一覧|提出物一覧|ポートフォリオ/, count: 0
    end
  end

  test 'job seeking dashboard preparation does not instantiate report product or work histories' do
    user = users(:kimura)
    user.update!(career_path: User.career_paths[:job_seeking])
    controller = HomeController.new
    controller.params = {}
    instantiated = []
    subscriber = ->(event) { instantiated << event.payload[:class_name] }
    controller.stub(:current_user, users(:advijirou)) do
      ActiveSupport::Notifications.subscribed(subscriber, 'instantiation.active_record') do
        controller.send(:display_dashboard)
        controller.instance_variable_get(:@job_seeking_users).load
      end
    end
    assert_empty instantiated & %w[Report Product Work]
  end

  test 'empty job seeking list hides card' do
    User.job_seeking.find_each { |user| user.update!(career_path: :unset) }
    sign_in users(:advijirou)
    get root_path
    assert_response :success
    assert_not_includes response.body, '就職活動中のユーザー'
  end

  private

  def assert_inactive_session_rejected(alert)
    assert_redirected_to root_path
    assert_equal alert, flash[:alert]
    assert_nil session[:user_id]
    assert_not_includes response.body, '最新のみんなの日報'

    follow_redirect!

    assert_response :success
    assert_select 'body.welcome-home'
    assert_not_includes response.body, '最新のみんなの日報'

    get users_path

    assert_redirected_to root_path
    assert_equal 'ログインしてください', flash[:alert]
  end

  def assert_job_seeking_counts(user)
    assert_select '.card-list-item', text: /#{user.login_name}/ do
      assert_select 'a', text: "日報一覧（#{user.reports.count}）"
      assert_select 'a', text: "提出物一覧（#{user.products.count}）"
      assert_select 'a', text: "ポートフォリオ（#{user.works.count}）"
    end
  end
end
