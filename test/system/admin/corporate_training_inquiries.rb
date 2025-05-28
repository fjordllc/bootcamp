# frozen_string_literal: true

require 'application_system_test_case'

class Admin::CorporateTrainingInquiriesTest < ApplicationSystemTestCase
  test 'displays corporate training inquiries with pagination' do
    visit_with_auth admin_corporate_training_inquiries_path, 'komagata'
    assert_equal '企業研修申し込み一覧 | FBC', title
    assert_selector 'h1', text: '企業研修申し込み一覧'
    assert_selector '.pagination'
    assert_text '株式会社テスト1'
    assert_text '株式会社テスト20'
    assert_selector '.card-list-item', count: 20
  end

  test 'does not display pagination when items are less than 20' do
    keep_ids = CorporateTrainingInquiry.limit(19).pluck(:id)
    CorporateTrainingInquiry.where.not(id: keep_ids).delete_all
    visit_with_auth admin_corporate_training_inquiries_path, 'komagata'
    assert_selector '.card-list-item', count: 19
    assert_no_selector '.pagination'
  end

  test 'inquiries sorted by created at desc' do
    visit_with_auth admin_corporate_training_inquiries_path, 'komagata'
    created_dates = all('.card-list-item .a-meta__value').map(&:text)
    assert_equal created_dates.sort.reverse, created_dates
  end

  test 'next and previous pagination links navigate correctly' do
    visit_with_auth admin_corporate_training_inquiries_path, 'komagata'
    all('a[rel="next"]')[0].click
    assert_text '株式会社テスト21'
    assert_text '株式会社テスト40'
    assert_selector '.card-list-item', count: 20

    all('a[rel="prev"]')[0].click
    assert_text '株式会社テスト1'
    assert_text '株式会社テスト20'
    assert_selector '.card-list-item', count: 20
  end

  test 'first and last pagination links navigate correctly' do
    visit_with_auth admin_corporate_training_inquiries_path, 'komagata'
    all('a.pagination__item-link.is-last')[0].click
    assert_text '株式会社テスト21'
    assert_text '株式会社テスト40'
    assert_selector '.card-list-item', count: 20

    all('a.pagination__item-link.is-first')[0].click
    assert_text '株式会社テスト1'
    assert_text '株式会社テスト20'
    assert_selector '.card-list-item', count: 20
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
    assert_text 'よろしくお願いします。'
    assert_text 'WEB検索'
  end
end
