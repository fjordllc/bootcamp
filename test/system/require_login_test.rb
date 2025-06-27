# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/login_assert_helper'

class RequireLoginTest < ApplicationSystemTestCase
  include LoginAssertHelper
  test 'redirect to welcome page and show message when you visit login required pages without login' do
    assert_login_required '/announcements'
    assert_login_required '/books'
    assert_login_required "/companies/#{companies(:company1).id}/products"
    assert_login_required "/companies/#{companies(:company1).id}/reports"
    assert_login_required "/companies/#{companies(:company1).id}/users"
    assert_login_required '/companies'
    assert_login_required "/courses/#{courses(:course1).id}/practices"
    assert_login_required '/current_user/bookmarks'
    assert_login_required '/current_user/password/edit'
    assert_login_required '/current_user/products'
    assert_login_required '/current_user/reports'
    assert_login_required '/current_user/watches'
    assert_login_required '/current_user/edit'
    assert_login_required '/events'
    assert_login_required '/generations'
    assert_login_required '/notifications'
    assert_login_required '/pages'
    assert_login_required '/portfolios'
    assert_login_required "/practices/#{practices(:practice1).id}/pages"
    assert_login_required "/practices/#{practices(:practice1).id}/products"
    assert_login_required "/practices/#{practices(:practice1).id}/questions"
    assert_login_required "/practices/#{practices(:practice1).id}/reports"
    assert_login_required '/products'
    assert_login_required '/questions'
    assert_login_required '/regular_events'
    assert_login_required '/reports'
    assert_login_required '/searchables'
    assert_login_required "/talks/#{talks(:talk8).id}"
    assert_login_required "/users/#{users(:hatsuno).id}/answers"
    assert_login_required "/users/#{users(:hatsuno).id}/comments"
    assert_login_required '/users/companies'
    assert_login_required "/users/#{users(:hatsuno).id}/products"
    assert_login_required "/users/#{users(:hatsuno).id}/questions"
    assert_login_required "/users/#{users(:hatsuno).id}/reports"
    assert_login_required '/users/tags'
    assert_login_required "/users/#{users(:hatsuno).id}/portfolio"
    assert_login_required "/works/#{works(:work1).id}"
  end

  test 'can visit these pages without login' do
    # app/controllers/comeback_controller.rb
    assert_no_login_required('/comeback/new', '休会からの復帰')

    # app/controllers/corporate_training_inquiry_comtroller.rb
    assert_no_login_required('/corporate_training_inquiry/new', '企業研修申し込みフォーム')

    # app/controllers/home_controller.rb
    assert_no_login_required('/', 'プラス戦力のスキルを身につける')
    assert_no_login_required('/test', 'TEST')

    # app/controllers/inquiries_controller.rb
    assert_no_login_required('/inquiry/new', 'お問い合わせ')

    # app/controllers/practices/completion_controller.rb
    assert_no_login_required("/practices/#{practices(:practice1).id}/completion", '修了しました')

    # app/controllers/user_sessions_controller.rb
    assert_no_login_required('/login', 'ログイン')
    assert_no_login_required('/logout', 'ログアウトしました。')

    # app/controllers/welcome_controller.rb
    assert_no_login_required('/welcome', 'プラス戦力のスキルを身につける')
    assert_no_login_required('/pricing', '料金')
    assert_no_login_required('/faq', 'FAQ')
    assert_no_login_required('/training', 'FBCの法人向けプログラミング研修')
    assert_no_login_required('/practices', '学習内容')
    assert_no_login_required('/tos', '利用規約')
    assert_no_login_required('/pp', 'プライバシーポリシー')
    assert_no_login_required('/law', '特定商取引法に基づく表記')
    assert_no_login_required('/coc', 'アンチハラスメントポリシー')
  end
end
