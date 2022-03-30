json.products do
  json.array! @products do |product|
    json.partial! "api/products/product", product: product
  end
end
json.total_pages @products.page(1).total_pages
json.all_submitted_products @all_submitted_products
