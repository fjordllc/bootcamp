# coding: utf-8
require 'test_helper'

class PracticeDecoratorTest < ActiveSupport::TestCase
  def setup
    @practice = Practice.new.extend PracticeDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
