# frozen_string_literal: true

require 'application_system_test_case'

class Admin::FAQTest < ApplicationSystemTestCase
  test 'display listing FAQs' do
    visit_with_auth '/admin/faqs', 'komagata'
    assert_text 'FAQ一覧'
  end

  test 'create FAQ' do
    visit_with_auth '/admin/faqs/new', 'komagata'
    within 'form[name=faq]' do
      fill_in 'faq[question]', with: 'test FAQ'
      fill_in 'faq[answer]', with: 'test FAQ'
      click_button '登録する'
    end
    assert_text 'FAQを作成しました。'
  end

  test 'update FAQ' do
    visit_with_auth "/admin/faqs/#{faqs(:faq1).id}/edit", 'komagata'
    within 'form[name=faq]' do
      fill_in 'faq[question]', with: 'updated FAQ'
      fill_in 'faq[answer]', with: 'updated FAQ'
      click_button '更新する'
    end
    assert_text 'FAQを更新しました。'
  end

  test "display answer's preview" do
    visit_with_auth '/admin/faqs/new', 'komagata'
    within 'form[name=faq]' do
      fill_in 'faq[answer]', with: 'updated FAQ'
    end
    assert_selector '.markdown-form__preview', text: 'updated FAQ'
  end

  test 'display link tag when answer has links' do
    visit_with_auth '/admin/faqs/new', 'komagata'
    within 'form[name=faq]' do
      fill_in 'faq[answer]', with: '[test](https://example.com)'
    end
    assert_selector '.markdown-form__preview a', text: 'test'
  end

  test 'delete FAQ' do
    visit_with_auth "/admin/faqs/#{faqs(:faq1).id}/edit", 'komagata'
    click_on '削除'
    page.driver.browser.switch_to.alert.accept
    assert_text 'FAQを削除しました。'
  end
end
