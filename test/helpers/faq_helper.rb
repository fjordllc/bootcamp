# frozen_string_literal: true

require 'test_helper'

class FAQHelperTest < ActionView::TestCase
  test '#format_question' do
    faq = faqs(:faq1)
    assert_equal format_question(faq.question), "#{faq.question}？"
  end

  test '#format_question returns a ？ mark' do
    faq = faqs(:faq1)
    faq.question += '？'
    assert_equal format_question(faq.question).count('？'), 1
  end
end
