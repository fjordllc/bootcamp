require "test_helper"

class ProductsTest <  ActiveSupport::TestCase
  test "returns true when product is checked" do
    assert users(:tanaka).products.checked?(practices(:practice_2))
  end

  test "returns false when product isn't checked" do
    assert_not users(:tanaka).products.checked?(practices(:practice_3))
  end

  test "returns false when no product" do
    assert_not users(:tanaka).products.checked?(practices(:practice_4))
  end
end
