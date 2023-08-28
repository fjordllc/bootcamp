# frozen_string_literal: true

require 'test_helper'

class RedirectionTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  class ExampleController < ApplicationController
  end

  def setup
    @controller = ExampleController.new
  end

  test '#redirect_url' do
    wip_product = Product.create!(
      body: 'saved as wip',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil,
      wip: true
    )
    assert_equal edit_product_url(wip_product), @controller.redirect_url(wip_product)
  end
end
