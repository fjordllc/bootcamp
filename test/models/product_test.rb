# frozen_string_literal: true

require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "delete associated notification" do
    user = users(:kimura)
    practice = practices(:practice_5)
    product = Product.create!(practice: practice, user: user, body: "test")
    product.destroy
    assert_not Notification.where(path: "/products/#{product.id}").exists?
  end

  test "adviser watches trainee product when trainee create product" do
    trainee = users(:kensyu)
    adviser = users(:senpai)
    practice = practices(:practice_2)
    product = Product.new(
      body: "test",
      user: trainee,
      practice: practice
    )
    product.save!
    assert_not_nil Watch.find_by(user: adviser, watchable: product)
  end
end
