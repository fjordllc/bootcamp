# frozen_string_literal: true

require 'application_system_test_case'

class JobSupportFAQsTest < ApplicationSystemTestCase
  FAQ_CATEGORY_NAME = '就職について'

  test 'shows FAQs' do
    category = FAQCategory.find_by(name: FAQ_CATEGORY_NAME)
    visit job_support_path
    assert_selector 'h3.lp-content-title', text: "#{FAQ_CATEGORY_NAME}\nよくある質問"
    assert_selector '.lp-faq', count: category.faqs.size
  end

  test 'hides FAQ title when none exist' do
    category = FAQCategory.find_by(name: FAQ_CATEGORY_NAME)
    category.faqs.destroy_all
    visit job_support_path
    assert_no_selector 'h3.lp-content-title', text: "#{FAQ_CATEGORY_NAME}\nよくある質問"
    assert_no_selector '.lp-faq'
  end

  test 'shows link to add FAQ when no FAQs exist and admin is logged in' do
    category = FAQCategory.find_by(name: FAQ_CATEGORY_NAME)
    category.faqs.destroy_all
    visit_with_auth job_support_path, 'komagata'
    assert_selector '.a-button', text: 'よくある質問を追加する'
  end
end
