# frozen_string_literal: true

require 'test_helper'

class FAQHelperTest < ActionView::TestCase
  test '#question_mark_with' do
    faq = faqs(:faq1)
    assert_equal question_mark_with(faq.question), "#{faq.question}？"
  end
end
