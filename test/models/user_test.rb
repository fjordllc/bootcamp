require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "admin?" do
    assert users(:komagata).admin?
    assert users(:machida).admin?
  end

  test "full_name" do
    assert_equal users(:komagata).full_name, "Komagata Masaki"
  end

  test "active?" do
    travel_to Time.new(2014, 1, 10, 0, 0, 0) do
      assert users(:komagata).active?
    end

    travel_to Time.new(2014, 1, 20, 0, 0, 0) do
      assert_not users(:machida).active?
    end
  end

  test "twitter_account" do
    user = users(:komagata)
    user.twitter_account = ""
    assert user.valid?
    user.twitter_account = "azAZ_09"
    assert user.valid?
    user.twitter_account = "-"
    assert user.invalid?
    user.twitter_account = "あ"
    assert user.invalid?
    user.twitter_account = ":"
    assert user.invalid?
    user.twitter_account = "A"*16
    assert user.invalid?
  end

  test "returns true when product of designated practice is checked" do
    assert users(:tanaka).has_checked_product?(practice: practices(:practice_2))
  end

  test "returns false when product of designated practice isn't checked" do
    assert_not users(:tanaka).has_checked_product?(practice: practices(:practice_3))
  end

  test "returns false when no product of designated practice" do
    assert_not users(:tanaka).has_checked_product?(practice: practices(:practice_4))
  end

  test "returns true when user has any checked products" do
    assert users(:tanaka).has_checked_product?
  end

  test "returns false when user doesn't have any checked products" do
    assert_not users(:kimura).has_checked_product?
  end

  test "returns false when user doesn't have any products" do
    assert_not users(:komagata).has_checked_product?
  end
end
