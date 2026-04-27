# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/login_assert_helper'

class RequireLoginTest < ApplicationSystemTestCase
  include LoginAssertHelper
  test 'can visit these pages without login' do
    # app/controllers/comeback_controller.rb
    assert_no_login_required('/comeback/new', '休会からの復帰')

    # app/controllers/corporate_training_inquiry_comtroller.rb
    assert_no_login_required('/corporate_training_inquiry/new', '企業研修申し込みフォーム')

    # app/controllers/home_controller.rb
    assert_no_login_required('/', 'プラス戦力のスキルを身につける')

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
