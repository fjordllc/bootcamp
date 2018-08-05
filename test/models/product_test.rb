require "test_helper"

class ProductsTest <  ActiveSupport::TestCase
  test "returns true when product is checked" do
    assert users(:tanaka).products.checked?(practices(:practice_2))
  end

  test "return false when product isn't checked" do
    assert_not users(:tanaka).products.checked?(practices(:practice_3))
  end
end
