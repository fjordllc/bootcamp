# frozen_string_literal: true

require 'application_system_test_case'

class FAQTest < ApplicationSystemTestCase
  test 'show listing FAQs' do
    visit faq_path
    assert_selector '.faqs-item', count: FAQ.all.size
  end

  test 'show listing FAQs by category' do
    visit '/faq?category=study_environment'

    study_environment_id = FAQCategory.find_by(name: 'study_environment').id
    assert_selector '.faqs-item', count: FAQ.where(faq_category_id: study_environment_id).size
  end
end
