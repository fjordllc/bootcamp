# frozen_string_literal: true

require 'test_helper'

class Products::PjordReviewRemovalTest < ActionDispatch::IntegrationTest
  test 'does not route product review requests to Pjord' do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path(
        "/products/#{products(:product1).id}/review_by_pjord",
        method: :post
      )
    end
  end
end
