# frozen_string_literal: true

require 'test_helper'

class SkipPracticeTest < ActiveSupport::TestCase
  fixtures :practices, :users

  test '# practice_belongs_to_user' do
    user1 = users(:kensyu)
    skip_practice = user1.skip_practices.new(practice: practices(:practice56))
    assert_not skip_practice.save
  end
end
