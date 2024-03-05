# frozen_string_literal: true

require 'application_system_test_case'

class FAQTest < ApplicationSystemTestCase
  test 'show listing FAQs' do
    visit faq_path
    assert_selector '.faqs-item', count: FAQ.all.size
  end

  test 'show listing FAQs by category' do
    visit '/faq?category=study_environment'
    assert_selector '.faqs-item', count: FAQ.where(category: 'study_environment').size
  end
end
