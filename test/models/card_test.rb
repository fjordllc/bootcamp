# frozen_string_literal: true

require 'test_helper'

class CardTest < ActiveSupport::TestCase
  setup do
    @card = Card.new
  end

  test '#create' do
    VCR.use_cassette 'customer/create' do
      customer = @card.create(users(:hatsuno), 'tok_visa')
      assert_equal 'cus_12345678', customer['id']
    end
  end

  test '#update' do
    VCR.use_cassette 'customer/update' do
      customer = @card.update('cus_12345678', 'tok_12345678')
      assert_equal 'cus_12345678', customer['id']
    end
  end

  test '#search' do
    VCR.use_cassette 'customer/list' do
      customer = @card.search(email: 'mentormentaro@example.com')
      assert_equal 'mentormentaro@example.com', customer['email']
    end
  end
end
