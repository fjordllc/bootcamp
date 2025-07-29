# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

module UserDecorator
  class ReportStatusTest < ActiveDecoratorTestCase
    test 'user_report_count_class' do
      assert_equal 'is-success', user_report_count_class(0)
      assert_equal 'is-success', user_report_count_class(1)

      assert_equal 'is-primary', user_report_count_class(2)
      assert_equal 'is-primary', user_report_count_class(4)

      assert_equal 'is-warning', user_report_count_class(5)
      assert_equal 'is-warning', user_report_count_class(9)

      assert_equal 'is-danger', user_report_count_class(10)
      assert_equal 'is-danger', user_report_count_class(100)
    end

    test 'unchecked_report_message' do
      user = users(:hajime)
      assert_equal "#{user.login_name}さんの日報へ", unchecked_report_message(0, user)
      assert_equal "#{user.login_name}さんの未チェックの日報はこれで最後です。", unchecked_report_message(1, user)
      assert_equal "#{user.login_name}さんの未チェックの日報が2件あります。", unchecked_report_message(2, user)
    end
  end
end
