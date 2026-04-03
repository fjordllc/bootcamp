# frozen_string_literal: true

class ProductsUserProductsComponentPreview < ViewComponent::Preview
  include PreviewHelper

  def default
    products = [mock_product('Rubyの基礎'), mock_product('Git入門')]
    render(Products::UserProductsComponent.new(
             products: products, current_user: build_mock_user, is_mentor: false
           ))
  end

  def empty
    render(Products::UserProductsComponent.new(
             products: [], current_user: build_mock_user, is_mentor: false
           ))
  end

  def as_mentor
    products = [mock_product('Rubyの基礎')]
    mentor = build_mock_user(id: 2, login_name: 'mentor', name: 'mentor', primary_role: 'mentor', icon_title: 'mentor')
    render(Products::UserProductsComponent.new(
             products: products, current_user: mentor, is_mentor: true
           ))
  end

  private

  def mock_product(practice_title)
    user = build_mock_user
    practice = OpenStruct.new(id: 1, title: practice_title)

    product = OpenStruct.new(
      id: rand(1..100), wip?: false, user: user, practice: practice,
      comments: [], published_at: 2.days.ago, created_at: 2.days.ago,
      updated_at: Time.current, checker_id: nil, checker: nil,
      checks: OpenStruct.new(last: nil)
    )
    product.define_singleton_method(:to_param) { product.id.to_s }
    product.define_singleton_method(:persisted?) { true }
    product.define_singleton_method(:model_name) { ActiveModel::Name.new(nil, nil, 'Product') }
    product
  end
end
