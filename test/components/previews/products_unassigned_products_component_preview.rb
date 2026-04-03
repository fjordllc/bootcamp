# frozen_string_literal: true

class ProductsUnassignedProductsComponentPreview < ViewComponent::Preview
  include PreviewHelper

  def default
    products = build_products
    grouped = group_products(products)

    render(Products::UnassignedProductsComponent.new(
             products: products,
             products_grouped_by_elapsed_days: grouped,
             is_mentor: true, is_admin: false,
             current_user_id: 2, reply_warning_days: 5
           ))
  end

  def with_urgent_products
    products = build_products(include_urgent: true)
    grouped = group_products(products)

    render(Products::UnassignedProductsComponent.new(
             products: products,
             products_grouped_by_elapsed_days: grouped,
             is_mentor: true, is_admin: false,
             current_user_id: 2, reply_warning_days: 5
           ))
  end

  def empty
    render(Products::UnassignedProductsComponent.new(
             products: [],
             products_grouped_by_elapsed_days: {},
             is_mentor: true, is_admin: false,
             current_user_id: 2, reply_warning_days: 5
           ))
  end

  private

  def mock_product(user_name:, days_ago:)
    user = build_mock_user(login_name: user_name, name: user_name, icon_title: user_name)
    practice = OpenStruct.new(id: 1, title: 'Rubyの基礎を理解する')
    published_at = days_ago.days.ago

    PreviewHelper::MockProduct.new(
      id: rand(1..100), wip: false, user: user, practice: practice,
      comments: [], published_at: published_at, created_at: published_at,
      updated_at: Time.current, checker_id: nil, checker: nil,
      checks: OpenStruct.new(last: nil)
    )
  end

  def build_products(include_urgent: false)
    products = [
      mock_product(user_name: 'yamada', days_ago: 1),
      mock_product(user_name: 'tanaka', days_ago: 3)
    ]
    if include_urgent
      products << mock_product(user_name: 'suzuki', days_ago: 7)
      products << mock_product(user_name: 'sato', days_ago: 10)
    end
    products
  end

  def group_products(products, reply_warning_days: 5)
    reply_alert_days = reply_warning_days + 1
    reply_deadline_days = reply_warning_days + 2

    products.group_by do |product|
      elapsed = ((Time.current - product.published_at) / 1.day).floor
      if elapsed >= reply_deadline_days then reply_deadline_days
      elsif elapsed >= reply_alert_days then reply_alert_days
      elsif elapsed >= reply_warning_days then reply_warning_days
      else elapsed
      end
    end
  end
end
