# frozen_string_literal: true

class ProductShowPresenter
  def initialize(product, practice)
    @product = product
    @practice = practice
  end

  def tweet_url
    @practice.tweet_url(
      Rails.application.routes.url_helpers.practice_completion_path(@practice.id)
    )
  end

  def recent_reports
    Report.list.where(user_id: @product.user.id).limit(10)
  end

  def user_products
    UserSubmittedProductsQuery.new(@product).call
  end

  def footprints
    Footprint.fetch_for_resource(@product)
  end

  def comments
    @product.comments.order(:created_at)
  end
end
