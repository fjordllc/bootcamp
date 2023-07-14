# frozen_string_literal: true

require 'test_helper'

class FaqTest < ActiveSupport::TestCase
  setup do
    @faq1 = faqs(:faq1)
  end

  test 'faq1 is valid' do
    assert @faq1.valid?
  end

  test 'faq1 is invalid if question is null' do
    @faq1.question = nil
    assert @faq1.invalid?
  end

  test 'faq1 is invalid if answer is null' do
    @faq1.answer = nil
    assert @faq1.invalid?
  end

  test 'new faq is invalid if question has already existed' do
    new_faq = faqs(:faq2)
    new_faq.question = @faq1.question
    assert new_faq.invalid?
  end

  test 'new faq is invalid if answer and question has already existed' do
    new_faq = faqs(:faq2)
    new_faq.answer = @faq1.answer
    new_faq.question = @faq1.question
    assert new_faq.invalid?
  end
end
