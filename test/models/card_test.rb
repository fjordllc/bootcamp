# frozen_string_literal: true

require 'test_helper'

class CardTest < ActiveSupport::TestCase
  setup do
    @card = Card.new
  end

  test '#create' do
    customer = @card.create(users(:hatsuno), 'tok_visa')
    assert customer['id'].present?
  end

  test '#update' do
    customer = @card.update('cus_12345678', 'tok_visa')
    assert customer['id'].present?
  end

  test '#search' do
    customer = @card.search(email: 'foo@example.com')
    assert_equal 'foo@example.com', customer['email']
  end
end
