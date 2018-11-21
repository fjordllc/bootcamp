# frozen_string_literal: true

require "application_system_test_case"

class NotificationsTest < ApplicationSystemTestCase
  setup do
    @user = User.find_by(login_name: "yamada")
    @admin = User.find_by(login_name: "komagata")
  end

  test "confirm notification count" do
    # 管理者からコメントが来た時(user)
    login_user "yamada", "testtest"
    click_link "日報"
    click_link "日報作成"
    fill_in "タイトル", with: "Rubyの基礎"
    select "23", from: "report[learning_times_attributes][0][finished_at(4i)]"
    fill_in "内容", with: "今日やったこと"
    click_button "提出"
    click_link "ログアウト"
    login_user "komagata", "testtest"
    click_link "日報"
    click_link "Rubyの基礎"
    click_button "日報を確認する"
    fill_in "comment_description", with: "今日の日報を確認しました"
    click_button "コメントする"
    click_link "ログアウト"
    login_user "yamada", "testtest"
    assert_equal 2, @user.notifications.size
    # 通知ベルの右上に出る件数の表示
    assert_text 1, first("li.has-count .header-notification-count").text

    # 同じURLの通知があった時、その中の1つが既読になったら同じURLの通知全てを既読にする
    first("li .header-links__link.js-drop-down__trigger.test-bell").click # 通知をクリック
    click_link "komagataさんからコメントが届きました。"
    @notification = Notification.find_by(id: @user.notifications.first)
    @notifications = @user.notifications.where(path: @notification.path)
    @notifications.each do |notification|
      assert_equal true, notification.read
    end

    # ユーザーからコメントが来た時(admin)
    click_link "日報"
    click_link "Rubyの基礎"
    fill_in "comment_description", with: "@komagata ユーザーからのコメント"
    click_button "コメントする"
    click_link "ログアウト"
    login_user "komagata", "testtest"
    assert_equal 1, @admin.notifications.size
    # 通知ベルの右上に出る件数の表示
    assert_text 1, first("li.has-count .header-notification-count").text
    click_link "ログアウト"

    # QAに回答が付いた時(user)
    login_user "yamada", "testtest"
    click_link "Q&A"
    click_link "テストの質問2"
    fill_in "answer_description", with: "@komagata ユーザーの回答"
    click_button "コメントを投稿"
    click_link "ログアウト"
    login_user "komagata", "testtest"
    assert_equal 2, @admin.notifications.size
    # 通知ベルの右上に出る件数の表示
    assert_text 2, first("li.has-count .header-notification-count").text
  end
end
