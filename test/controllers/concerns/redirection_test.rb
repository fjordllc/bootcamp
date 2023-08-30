# frozen_string_literal: true

require 'test_helper'

class RedirectionTest < ActiveSupport::TestCase
  class ExampleController < ApplicationController
    include Redirection

    def call_redirect_url(resource)
      redirect_url(resource)
    end
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
    assert_equal url, @controller.call_redirect_url(wip_product)

    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice7),
      checker_id: nil
    )

    url = "http://test.host/products/#{product.id}"
    assert_equal url, @controller.call_redirect_url(product)
  end
end
