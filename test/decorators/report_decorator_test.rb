# frozen_string_literal: true

require "test_helper"

class ReportDecoratorTest < ActiveSupport::TestCase
  def setup
    @report = ActiveDecorator::Decorator.instance.decorate(reports(:report_1))
  end

  test "#total_learning_time" do
    assert_equal "7時間", @report.total_learning_time
  end
end
