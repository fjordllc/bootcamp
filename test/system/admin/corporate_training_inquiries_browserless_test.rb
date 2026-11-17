# frozen_string_literal: true

require 'browserless_system_test_case'

class Admin::CorporateTrainingInquiriesBrowserlessTest < BrowserlessSystemTestCase
  test 'inquiries sorted by created at desc' do
    visit_with_auth admin_corporate_training_inquiries_path, 'komagata'
    created_dates = all('.card-list-item .a-meta__value').map(&:text)
    assert_equal created_dates.sort.reverse, created_dates
  end

  test 'displays corporate training inquiry details correctly' do
    inquiry = corporate_training_inquiries(:corporate_training_inquiry1)
    visit_with_auth admin_corporate_training_inquiry_path(inquiry), 'komagata'
    assert_equal '企業研修申し込み | FBC', title
    assert_selector 'h1', text: '株式会社テスト1（テストユーザー1様）'
    assert_text '株式会社テスト1（担当者: テストユーザー1様）'
    assert_text 'test1@example.com'
    assert_text '2030年12月02日(月) 10:00'
    assert_text '2030年12月03日(火) 10:00'
    assert_text '2030年12月04日(水) 10:00'
    assert_text '10人'
    assert_text '1ヶ月'
    assert_text '希望しない'
    assert_text 'よろしくお願いします。'
    assert_text 'WEB検索'
  end

  test 'displays subsidy consultation request' do
    inquiry = corporate_training_inquiries(:corporate_training_inquiry40)
    visit_with_auth admin_corporate_training_inquiry_path(inquiry), 'komagata'
    assert_text '希望する'
  end
end
