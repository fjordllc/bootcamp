# coding: utf-8
require 'test_helper'

class UserDecoratorTest < ActiveSupport::TestCase
  def setup
    @user = User.new.extend UserDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
