json.products do
  json.array! @products do |product|
    json.partial! "api/products/product", product: product
  end
end
json.products_grouped_by_elapsed_days do
  json.array! @products_grouped_by_elapsed_days do |_, products|
    json.array! products do |product|
      json.partial! "api/products/product", product: product
    end
  end
end
json.total_pages @products.page(1).total_pages
