# frozen_string_literal: true

require 'application_system_test_case'

class FAQTest < ApplicationSystemTestCase
  test 'show listing FAQs' do
    visit faq_path
    FAQ.all.each { |faq| assert_text "#{faq.question}？" }
  end
end
