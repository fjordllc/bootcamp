json.products do
  json.array! @products do |product|
    json.partial! "api/products/product", product: product
  end
end
json.total_pages @products.page(1).total_pages
json.latest_product_submitted_just_5days @latest_product_submitted_just_5days
json.latest_product_submitted_just_6days @latest_product_submitted_just_6days
json.latest_product_submitted_over_7days @latest_product_submitted_over_7days
