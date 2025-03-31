# frozen_string_literal: true

require 'application_system_test_case'

class GrantCourseApplicationsTest < ApplicationSystemTestCase
  test 'user can apply for grant course' do
    GrantCourseApplicationsController.stub_any_instance(:valid_recaptcha?, true) do
      visit new_grant_course_application_path

      assert_text '給付金対応コース受講申請'

      fill_in 'grant_course_application[last_name]', with: '山田'
      fill_in 'grant_course_application[first_name]', with: '太郎'
      fill_in 'grant_course_application[email]', with: 'test@example.com'
      fill_in 'grant_course_application_zip1', with: '123'
      fill_in 'grant_course_application_zip2', with: '4567'
      select '東京都', from: '都道府県'
      fill_in '市区町村', with: '渋谷区渋谷1-1-1'
      fill_in '建物名・部屋番号', with: 'サンプルビル101'
      fill_in 'grant_course_application_tel1', with: '090'
      fill_in 'grant_course_application_tel2', with: '1234'
      fill_in 'grant_course_application_tel3', with: '5678'
      check 'grant_course_application_trial_period', allow_label_click: true, visible: false
      check 'grant_course_application_privacy_policy', allow_label_click: true, visible: false

      click_button '申請する'

      assert_text '給付金対応コース受講申請完了'
      assert_text '受講申請が完了しました。ありがとうございます。'
      assert_text '担当者より折り返しご連絡いたします。'
    end
  end

  test 'user sees error messages when submitting invalid form' do
    GrantCourseApplicationsController.stub_any_instance(:valid_recaptcha?, true) do
      visit new_grant_course_application_path

      # Submit without entering any information
      click_button '申請する'

      assert_text '入力内容にエラーがあります'
      assert_text '姓を入力してください'
      assert_text '名を入力してください'
      assert_text 'メールアドレスを入力してください'
      assert_text '郵便番号（前半）を入力してください'
      assert_text '郵便番号（後半）を入力してください'
      assert_text '都道府県を入力してください'
      assert_text '市区町村を入力してください'
      assert_text '電話番号（前半）を入力してください'
      assert_text '電話番号（中央）を入力してください'
      assert_text '電話番号（後半）を入力してください'
      assert_text '個人情報の取り扱いを受諾してください'
    end
  end
end
