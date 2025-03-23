# frozen_string_literal: true

require 'application_system_test_case'

class GrantCourseApplicationsTest < ApplicationSystemTestCase
  test 'user can apply for grant course' do
    visit new_grant_course_application_path

    assert_text '給付金対応コース申し込み'

    # Set up Recaptcha mock
    GrantCourseApplicationsController.any_instance.stubs(:valid_recaptcha?).returns(true)

    fill_in '姓', with: '山田'
    fill_in '名', with: '太郎'
    fill_in 'メールアドレス', with: 'test@example.com'
    fill_in 'grant_course_application_zip1', with: '123'
    fill_in 'grant_course_application_zip2', with: '4567'
    select '東京都', from: '都道府県'
    fill_in '市区町村', with: '渋谷区渋谷1-1-1'
    fill_in '建物名・部屋番号', with: 'サンプルビル101'
    fill_in 'grant_course_application_tel1', with: '090'
    fill_in 'grant_course_application_tel2', with: '1234'
    fill_in 'grant_course_application_tel3', with: '5678'
    check 'お試し期間利用希望'
    check '下記の個人情報の取り扱いに同意する'

    click_button '送信'

    assert_text '給付金対応コース申し込み完了'
    assert_text '給付金対応コースへの申し込みが完了しました。ありがとうございます。'
    assert_text '担当者より折り返しご連絡いたします。'
  end

  test 'user sees error messages when submitting invalid form' do
    visit new_grant_course_application_path

    # Set up Recaptcha mock
    GrantCourseApplicationsController.any_instance.stubs(:valid_recaptcha?).returns(true)

    # Submit without entering any information
    click_button '送信'

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
    assert_text '個人情報の取り扱いに同意してください'
  end
end
