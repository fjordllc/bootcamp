require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'full_name' do
    assert_equal users(:komagata).full_name, 'Komagata Masaki'
  end

  test 'active?' do
    travel_to Time.new(2014, 1, 20, 0, 0, 0) do
      assert users(:komagata).active?
    end

    travel_to Time.new(2014, 1, 20, 0, 0, 0) do
      assert_not users(:machida).active?
    end
  end
end
