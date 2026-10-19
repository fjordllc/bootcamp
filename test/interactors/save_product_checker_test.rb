# frozen_string_literal: true

require 'test_helper'

class SaveProductCheckerTest < ActiveSupport::TestCase
  test 'call' do
    checker = users(:komagata)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil
    )
    assert SaveProductChecker.call(product:, user_id: checker.id).success?
  end
end
