# frozen_string_literal: true

require "application_system_test_case"

class NotificationsTest < ApplicationSystemTestCase
  test "do not send mail if user deny mail" do
    login_user "kimura", "testtest"
    visit "/reports/#{reports(:report_8).id}"
    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "test")
    end
    click_button "コメントする"

    if ActionMailer::Base.deliveries.present?
      last_mail = ActionMailer::Base.deliveries.last
      assert_not_equal "[Bootcamp] kimuraさんからコメントが届きました。", last_mail.subject
    end
  end

  test "don't notify the same report" do
    login_user "komagata", "testtest"
    visit "/notifications"
    click_link "全て既読にする"

    login_user "kensyu", "testtest"
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "none"
    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("23")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("00")
    click_button "提出"

    find(".js-markdown").set("login_nameの補完テスト: @komagata\n")
    click_button "コメントする"
    assert_text "login_nameの補完テスト: @komagata"
    assert_selector :css, "a[href='/users/komagata']"

    login_user "komagata", "testtest"
    visit "/notifications"
    assert_no_text "kensyuさんがはじめての日報を書きました！"
    assert_text "kensyuさんからメンションがきました。"
  end

  test "don't notify the same product" do
    login_user "komagata", "testtest"
    visit "/notifications"
    click_link "全て既読にする"

    login_user "kensyu", "testtest"
    visit "/products/new?practice_id=#{practices(:practice_3).id}"
    within("#new_product") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"
    assert_text "提出物を作成しました。"

    fill_in("js-new-comment", with: "test @komagata")
    click_button "コメントする"
    assert_text "test @komagata"

    login_user "komagata", "testtest"
    visit "/notifications"
    assert_no_text "kensyuさんが提出しました。"
    assert_no_text "kensyuさんからメンションがきました。"
    assert_text "あなたがウォッチしている【 「PC性能の見方を知る」の提出物 】にコメントが投稿されました。"
  end
end
