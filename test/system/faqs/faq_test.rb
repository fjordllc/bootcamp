# frozen_string_literal: true

require 'application_system_test_case'

class FAQTest < ApplicationSystemTestCase
  test 'show listing FAQs' do
    visit faq_path
    assert_selector '.lp-faq', count: FAQ.all.size
  end

  test 'show listing FAQs by category' do
    visit '/faq?category=学習環境について'
    category = FAQCategory.find_by(name: '学習環境について').id
    assert_selector '.lp-faq', count: FAQ.where(faq_category: category).size
  end
end
