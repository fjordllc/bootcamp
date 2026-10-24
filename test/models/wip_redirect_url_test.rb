# frozen_string_literal: true

require 'test_helper'

class WipRedirectUrlTest < ActiveSupport::TestCase
  def setup
    @controller = ApplicationController.new
    @controller.request = ActionDispatch::TestRequest.create
  end

  test '.resolve' do
    wip_product = Product.create!(
      body: 'saved as wip',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil,
      wip: true
    )

    url = "http://test.host/products/#{wip_product.id}/edit"
    assert_equal url, WipRedirectUrl.resolve(@controller, wip_product)

    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice7),
      checker_id: nil
    )

    url = "http://test.host/products/#{product.id}"
    assert_equal url, WipRedirectUrl.resolve(@controller, product)
  end
end
