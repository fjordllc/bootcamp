# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
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

  def assert_job_seeking_counts(user)
    assert_select '.card-list-item', text: /#{user.login_name}/ do
      assert_select 'a', text: "日報一覧（#{user.reports.count}）"
      assert_select 'a', text: "提出物一覧（#{user.products.count}）"
      assert_select 'a', text: "ポートフォリオ（#{user.works.count}）"
    end
  end
end
