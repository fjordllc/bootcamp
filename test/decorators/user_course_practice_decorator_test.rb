# frozen_string_literal: true

require 'test_helper'

class UserCoursePracticeDecoratorTest < ActiveSupport::TestCase
  def setup
    @user_course_practice = UserCoursePractice.new.extend UserCoursePracticeDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
