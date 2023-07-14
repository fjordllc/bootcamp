# frozen_string_literal: true

require 'application_system_test_case'

class FAQTest < ApplicationSystemTestCase
  test 'show listing FAQs' do
    visit faq_path
    assert_selector '.faqs-item', count: FAQ.all.size
  end
end
