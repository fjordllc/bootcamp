# frozen_string_literal: true

# require "application_system_test_case"

# class PageTabsTest < ApplicationSystemTestCase
#   test "when login user is admin, practice's tab members are practice and reports and questions and products" do
#     login_user "machida", "testtest"

#     assert_text "プラクティス"
#     click_link "プラクティス"
#     first(".category-practices-item__title-link").click

#     assert_text "終了条件"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プラクティス", first(".page-tabs__item-link.is-active").text

#     page_tabs = all(".page-tabs__item-link")
#     assert_equal 4, page_tabs.size
#     assert_equal "プラクティス", page_tabs[0].text
#     assert_equal "日報", page_tabs[1].text
#     assert_equal "質問", page_tabs[2].text
#     assert_equal "提出物", page_tabs[3].text

#     practice_id = current_path.split("/").last.to_i

#     all(".page-tabs__item-link")[0].click

#     assert_text "終了条件"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プラクティス", first(".page-tabs__item-link.is-active").text

#     all(".page-tabs__item-link")[1].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "日報", first(".page-tabs__item-link.is-active").text
#     expected_report_counts = Practice.find(practice_id).reports.size
#     actual_report_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_report_counts, actual_report_counts

#     all(".page-tabs__item-link")[2].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "質問", first(".page-tabs__item-link.is-active").text
#     expected_question_counts = Practice.find(practice_id).questions.not_solved.size
#     actual_question_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_question_counts, actual_question_counts

#     all(".page-tabs__item-link")[3].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "提出物", first(".page-tabs__item-link.is-active").text
#     expected_product_counts = Practice.find(practice_id).products.size
#     actual_product_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_product_counts, actual_product_counts
#   end

#   test "when login user is adviser, practice's tab members are practice and reports and questions and products" do
#     login_user "mineo", "testtest"

#     assert_text "プラクティス"
#     click_link "プラクティス"
#     first(".category-practices-item__title-link").click

#     assert_text "終了条件"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プラクティス", first(".page-tabs__item-link.is-active").text

#     page_tabs = all(".page-tabs__item-link")
#     assert_equal 4, page_tabs.size
#     assert_equal "プラクティス", page_tabs[0].text
#     assert_equal "日報", page_tabs[1].text
#     assert_equal "質問", page_tabs[2].text
#     assert_equal "提出物", page_tabs[3].text

#     practice_id = current_path.split("/").last.to_i

#     all(".page-tabs__item-link")[0].click

#     assert_text "終了条件"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プラクティス", first(".page-tabs__item-link.is-active").text

#     all(".page-tabs__item-link")[1].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "日報", first(".page-tabs__item-link.is-active").text
#     expected_report_counts = Practice.find(practice_id).reports.size
#     actual_report_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_report_counts, actual_report_counts

#     all(".page-tabs__item-link")[2].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "質問", first(".page-tabs__item-link.is-active").text
#     expected_question_counts = Practice.find(practice_id).questions.not_solved.size
#     actual_question_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_question_counts, actual_question_counts

#     all(".page-tabs__item-link")[3].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "提出物", first(".page-tabs__item-link.is-active").text
#     expected_product_counts = Practice.find(practice_id).products.size
#     actual_product_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_product_counts, actual_product_counts
#   end

#   test "when login user is student and has a checked product, practice's tab members are practice and reports and questions and products" do
#     login_user "yamada", "testtest"

#     assert_text "プラクティス"
#     click_link "プラクティス"
#     all(".category-practices-item__title-link")[1].click

#     assert_text "終了条件"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プラクティス", first(".page-tabs__item-link.is-active").text

#     page_tabs = all(".page-tabs__item-link")
#     assert_equal 4, page_tabs.size
#     assert_equal "プラクティス", page_tabs[0].text
#     assert_equal "日報", page_tabs[1].text
#     assert_equal "質問", page_tabs[2].text
#     assert_equal "提出物", page_tabs[3].text

#     practice_id = current_path.split("/").last.to_i

#     all(".page-tabs__item-link")[0].click

#     assert_text "終了条件"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プラクティス", first(".page-tabs__item-link.is-active").text

#     all(".page-tabs__item-link")[1].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "日報", first(".page-tabs__item-link.is-active").text
#     expected_report_counts = Practice.find(practice_id).reports.size
#     actual_report_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_report_counts, actual_report_counts

#     all(".page-tabs__item-link")[2].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "質問", first(".page-tabs__item-link.is-active").text
#     expected_question_counts = Practice.find(practice_id).questions.not_solved.size
#     actual_question_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_question_counts, actual_question_counts

#     all(".page-tabs__item-link")[3].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "提出物", first(".page-tabs__item-link.is-active").text
#     expected_product_counts = Practice.find(practice_id).products.size
#     actual_product_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_product_counts, actual_product_counts
#   end

#   test "when login user is student and doesn't have a checked product, practice's tab members are practice and reports and questions" do
#     login_user "kimura", "testtest"

#     assert_text "プラクティス"
#     click_link "プラクティス"
#     first(".category-practices-item__title-link").click

#     assert_text "終了条件"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プラクティス", first(".page-tabs__item-link.is-active").text

#     page_tabs = all(".page-tabs__item-link")
#     assert_equal 4, page_tabs.size
#     assert_equal "プラクティス", page_tabs[0].text
#     assert_equal "日報", page_tabs[1].text
#     assert_equal "質問", page_tabs[2].text
#     assert_equal "提出物", page_tabs[3].text

#     practice_id = current_path.split("/").last.to_i

#     all(".page-tabs__item-link")[0].click

#     assert_text "終了条件"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プラクティス", first(".page-tabs__item-link.is-active").text

#     all(".page-tabs__item-link")[1].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "日報", first(".page-tabs__item-link.is-active").text
#     expected_report_counts = Practice.find(practice_id).reports.size
#     actual_report_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_report_counts, actual_report_counts

#     all(".page-tabs__item-link")[2].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "質問", first(".page-tabs__item-link.is-active").text
#     expected_question_counts = Practice.find(practice_id).questions.not_solved.size
#     actual_question_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_question_counts, actual_question_counts

#     all(".page-tabs__item-link")[3].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "提出物", first(".page-tabs__item-link.is-active").text
#   end

#   test "when login user is admin, user's tab members are user and practices and reports and comments and products" do
#     login_user "machida", "testtest"

#     assert_text "ユーザー"
#     click_link "ユーザー"

#     last_displayed_student = all(".users-item__name-link").last
#     assert_equal "kimura", last_displayed_student.text
#     last_displayed_student.click

#     assert_text "Kimura Tadasi"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     page_tabs = all(".page-tabs__item-link")
#     assert_equal 4, page_tabs.size
#     assert_equal "プロフィール", page_tabs[0].text
#     assert_equal "日報", page_tabs[1].text
#     assert_equal "コメント", page_tabs[2].text
#     assert_equal "提出物", page_tabs[3].text

#     user_id = current_path.split("/").last.to_i

#     all(".page-tabs__item-link")[0].click

#     assert_text "Kimura Tadasi"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     all(".page-tabs__item-link")[1].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "日報", first(".page-tabs__item-link.is-active").text
#     expected_report_counts = User.find(user_id).reports.size
#     actual_report_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_report_counts, actual_report_counts

#     all(".page-tabs__item-link")[2].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "コメント", first(".page-tabs__item-link.is-active").text
#     expected_comment_counts = User.find(user_id).comments.where(commentable_type: "Report").size
#     actual_comment_counts = all(".thread-comment__title-link").size
#     assert_equal expected_comment_counts, actual_comment_counts

#     all(".page-tabs__item-link")[3].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "提出物", first(".page-tabs__item-link.is-active").text
#     expected_product_counts = User.find(user_id).products.size
#     actual_product_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_product_counts, actual_product_counts
#   end

#   test "when login user is adviser, user's tab members are user and practices and reports and comments and products" do
#     login_user "mineo", "testtest"

#     assert_text "ユーザー"
#     click_link "ユーザー"

#     # last_displayed_student = all(".users-item__name-link").last
#     # assert_equal "kimura", last_displayed_student.text
#     # last_displayed_student.click

#     click_link "kimura"

#     assert_text "Kimura Tadasi"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     page_tabs = all(".page-tabs__item-link")
#     assert_equal 4, page_tabs.size
#     assert_equal "プロフィール", page_tabs[0].text
#     assert_equal "日報", page_tabs[1].text
#     assert_equal "コメント", page_tabs[2].text
#     assert_equal "提出物", page_tabs[3].text

#     user_id = current_path.split("/").last.to_i

#     all(".page-tabs__item-link")[0].click

#     assert_text "Kimura Tadasi"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     all(".page-tabs__item-link")[1].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "日報", first(".page-tabs__item-link.is-active").text
#     expected_report_counts = User.find(user_id).reports.size
#     actual_report_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_report_counts, actual_report_counts

#     all(".page-tabs__item-link")[2].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "コメント", first(".page-tabs__item-link.is-active").text
#     expected_comment_counts = User.find(user_id).comments.where(commentable_type: "Report").size
#     actual_comment_counts = all(".thread-comment__title-link").size
#     assert_equal expected_comment_counts, actual_comment_counts

#     all(".page-tabs__item-link")[3].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "提出物", first(".page-tabs__item-link.is-active").text
#     expected_product_counts = User.find(user_id).products.size
#     actual_product_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_product_counts, actual_product_counts
#   end

#   test "when login user is student and target user is current user, user's tab members are user and practices and reports and comments and products" do
#     login_user "hatsuno", "testtest"

#     assert_text "ユーザー"
#     click_link "ユーザー"

#     first_displayed_student = first(".users-item__name-link")
#     assert_equal "hatsuno", first_displayed_student.text
#     first_displayed_student.click

#     assert_text "Hatsuno Shinji"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     page_tabs = all(".page-tabs__item-link")
#     assert_equal 4, page_tabs.size
#     assert_equal "プロフィール", page_tabs[0].text
#     assert_equal "日報", page_tabs[1].text
#     assert_equal "コメント", page_tabs[2].text
#     assert_equal "提出物", page_tabs[3].text

#     user_id = current_path.split("/").last.to_i

#     all(".page-tabs__item-link")[0].click

#     assert_text "Hatsuno Shinji"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     all(".page-tabs__item-link")[1].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "日報", first(".page-tabs__item-link.is-active").text
#     expected_report_counts = User.find(user_id).reports.size
#     actual_report_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_report_counts, actual_report_counts

#     all(".page-tabs__item-link")[2].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "コメント", first(".page-tabs__item-link.is-active").text
#     expected_comment_counts = User.find(user_id).comments.where(commentable_type: "Report").size
#     actual_comment_counts = all(".thread-comment__title-link").size
#     assert_equal expected_comment_counts, actual_comment_counts

#     all(".page-tabs__item-link")[3].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "提出物", first(".page-tabs__item-link.is-active").text
#     expected_product_counts = User.find(user_id).products.size
#     actual_product_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_product_counts, actual_product_counts
#   end

#   test "when login user is student and target user has a checked product and login user also has it, user's tab members are user and practices and reports and comments and products" do
#     login_user "hatsuno", "testtest"

#     assert_text "ユーザー"
#     click_link "ユーザー"

#     first_displayed_student = first(".users-item__name-link")
#     assert_equal "hatsuno", first_displayed_student.text
#     first_displayed_student.click

#     assert_text "Hatsuno Shinji"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     page_tabs = all(".page-tabs__item-link")
#     assert_equal 4, page_tabs.size
#     assert_equal "プロフィール", page_tabs[0].text
#     assert_equal "日報", page_tabs[1].text
#     assert_equal "コメント", page_tabs[2].text
#     assert_equal "提出物", page_tabs[3].text

#     user_id = current_path.split("/").last.to_i

#     all(".page-tabs__item-link")[0].click

#     assert_text "Hatsuno Shinji"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     all(".page-tabs__item-link")[1].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "日報", first(".page-tabs__item-link.is-active").text
#     expected_report_counts = User.find(user_id).reports.size
#     actual_report_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_report_counts, actual_report_counts

#     all(".page-tabs__item-link")[2].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "コメント", first(".page-tabs__item-link.is-active").text
#     expected_comment_counts = User.find(user_id).comments.where(commentable_type: "Report").size
#     actual_comment_counts = all(".thread-comment__title-link").size
#     assert_equal expected_comment_counts, actual_comment_counts

#     all(".page-tabs__item-link")[3].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "提出物", first(".page-tabs__item-link.is-active").text
#     assert_equal 1, all(".thread-list-item__title-link").size
#   end

#   test "when login user is student and target user has a checked product but login user doesn't have it, user's tab members are user and practices and reports" do
#     login_user "kimura", "testtest"

#     assert_text "ユーザー"
#     click_link "ユーザー"

#     assert_text "卒業生"
#     click_link "卒業生"

#     first_displayed_student = first(".users-item__name-link")
#     assert_equal "tanaka", first_displayed_student.text
#     first_displayed_student.click

#     assert_text "Tanaka Taro"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     page_tabs = all(".page-tabs__item-link")
#     assert_equal 3, page_tabs.size
#     assert_equal "プロフィール", page_tabs[0].text
#     assert_equal "日報", page_tabs[1].text
#     assert_equal "コメント", page_tabs[2].text

#     user_id = current_path.split("/").last.to_i

#     all(".page-tabs__item-link")[0].click

#     assert_text "Tanaka Taro"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     all(".page-tabs__item-link")[1].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "日報", first(".page-tabs__item-link.is-active").text
#     expected_report_counts = User.find(user_id).reports.size
#     actual_report_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_report_counts, actual_report_counts

#     all(".page-tabs__item-link")[2].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "コメント", first(".page-tabs__item-link.is-active").text
#     expected_comment_counts = User.find(user_id).comments.where(commentable_type: "Report").size
#     actual_comment_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_comment_counts, actual_comment_counts
#   end

#   test "when login user is student and target user doesn't have a checked product, user's tab members are user and practices and reports and commnets" do
#     login_user "yamada", "testtest"

#     assert_text "ユーザー"
#     click_link "ユーザー"

#     # last_displayed_student = all(".users-item__name-link").last
#     # assert_equal "kimura", last_displayed_student.text
#     # last_displayed_student.click

#     assert_text "Kimura Tadasi"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     page_tabs = all(".page-tabs__item-link")
#     assert_equal 4, page_tabs.size
#     assert_equal "プロフィール", page_tabs[0].text
#     assert_equal "日報", page_tabs[1].text
#     assert_equal "コメント", page_tabs[2].text
#     assert_equal "提出物", page_tabs[3].text

#     user_id = current_path.split("/").last.to_i

#     all(".page-tabs__item-link")[0].click

#     assert_text "Kimura Tadasi"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "プロフィール", first(".page-tabs__item-link.is-active").text

#     all(".page-tabs__item-link")[1].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "日報", first(".page-tabs__item-link.is-active").text
#     expected_report_counts = User.find(user_id).reports.size
#     actual_report_counts = all(".thread-list-item__title-link").size
#     assert_equal expected_report_counts, actual_report_counts

#     all(".page-tabs__item-link")[2].click

#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "コメント", first(".page-tabs__item-link.is-active").text
#     expected_comment_counts = User.find(user_id).comments.where(commentable_type: "Report").size
#     actual_comment_counts = all(".thread-comment__title-link").size
#     assert_equal expected_comment_counts, actual_comment_counts

#     all(".page-tabs__item-link")[3].click

#     assert_text "提出物"
#     assert_equal 1, all(".page-tabs__item-link.is-active").length
#     assert_equal "提出物", first(".page-tabs__item-link.is-active").text
#   end
# end
