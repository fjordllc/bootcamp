# frozen_string_literal: true

require 'test_helper'

class RequireLoginIntegrationTest < ActionDispatch::IntegrationTest
  test 'login required pages redirect to root with message without login' do
    login_required_paths.each do |path|
      get path

      assert_redirected_to root_path, "Expected #{path} to require login"
      assert_equal 'ログインしてください', flash[:alert], "Expected #{path} to show login alert"
    end
  end

  private

  def login_required_paths
    [
      announcements_path,
      books_path,
      company_products_path(companies(:company1)),
      company_reports_path(companies(:company1)),
      company_users_path(companies(:company1)),
      companies_path,
      course_practices_path(courses(:course1)),
      current_user_bookmarks_path,
      edit_current_user_password_path,
      current_user_products_path,
      current_user_reports_path,
      current_user_watches_path,
      edit_current_user_path,
      events_path,
      generations_path,
      notifications_path,
      pages_path,
      portfolios_path,
      practice_pages_path(practices(:practice1)),
      practice_products_path(practices(:practice1)),
      practice_questions_path(practices(:practice1)),
      practice_reports_path(practices(:practice1)),
      products_path,
      questions_path,
      regular_events_path,
      reports_path,
      searchables_path,
      talk_path(talks(:talk8)),
      user_answers_path(users(:hatsuno)),
      user_comments_path(users(:hatsuno)),
      users_companies_path,
      user_products_path(users(:hatsuno)),
      user_questions_path(users(:hatsuno)),
      user_reports_path(users(:hatsuno)),
      users_tags_path,
      user_portfolio_path(users(:hatsuno)),
      work_path(works(:work1))
    ]
  end
end
