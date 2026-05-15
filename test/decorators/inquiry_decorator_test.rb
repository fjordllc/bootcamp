# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class InquiryDecoratorTest < ActiveDecoratorTestCase
  setup do
    @inquiry = decorate(inquiries(:inquiry1))
  end

  test '#sender_name_and_email' do
    assert_equal 'inquiry1 様 （inquiry1@example.com）', @inquiry.sender_name_and_email
  end
end
