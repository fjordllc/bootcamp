# frozen_string_literal: true

require 'test_helper'

class RedirectionTest < ActiveSupport::TestCase
  class ExampleController < ApplicationController
    include Redirection
  end

  def setup
    @controller = ExampleController.new
    @controller.request = ActionDispatch::TestRequest.create
  end

  test '#redirect_url' do
    wip_product = Product.create!(
      body: 'saved as wip',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil,
      wip: true
    )

    url = "http://test.host/products/#{wip_product.id}/edit"
    assert_equal url, @controller.redirect_url(wip_product)
  end
end
