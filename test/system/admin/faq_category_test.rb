# frozen_string_literal: true

require 'application_system_test_case'

class Admin::FaqCategoryest < ApplicationSystemTestCase
  test 'display listing FAQCategory' do
    visit_with_auth '/admin/faq_categories', 'komagata'
    has_css? 'h1.page-main-header__title', text: 'FAQカテゴリー一覧'
  end

  test 'create FAQCategory' do
    visit_with_auth '/admin/faq_categories/new', 'komagata'
    within 'form[name=faq_category]' do
      fill_in 'faq_category[name]', with: 'test FAQCategory'
      click_button '登録する'
    end
    assert_text 'FAQカテゴリーを作成しました。'
  end

  test 'update FAQ' do
    visit_with_auth "/admin/faq_categories/#{faq_categories(:faq_category1).id}/edit", 'komagata'
    within 'form[name=faq_category]' do
      fill_in 'faq_category[name]', with: 'updated FAQCategory'
      click_button '更新する'
    end
    assert_text 'FAQカテゴリーを更新しました。'
  end

  test 'delete FAQ' do
    visit_with_auth "/admin/faq_categories/#{faq_categories(:faq_category1).id}/edit", 'komagata'
    click_on '削除'
    page.driver.browser.switch_to.alert.accept
    assert_text 'FAQカテゴリーを削除しました。'
  end
end
