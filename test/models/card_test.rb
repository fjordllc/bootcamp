# frozen_string_literal: true

require "test_helper"

class CardTest < ActiveSupport::TestCase
  test "create" do
    stub_create_card!

    customer = Card.create(users(:hatsuno), "tok_visa")
    assert customer["id"].present?
  end

  test "update" do
    stub_update_card!

    customer = Card.update("cus_12345678", "tok_visa")
    assert customer["id"].present?
  end

  test "search" do
    stub_search_card!

    customer = Card.search(email: "foo@example.com")
    assert_equal "foo@example.com", customer["email"]
  end
end
