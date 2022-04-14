json.products do
  json.array! @products do |product|
    json.partial! "api/products/product", product: product
  end
end

json.products_grouped_by_elapsed_days do
  json.array! @products_grouped_by_elapsed_days do |elapsed_days, products|
    json.elapsed_days elapsed_days
    json.products do
      json.array! products do |product|
        json.partial! "api/products/product", product: product
      end
    end
  end
end
json.total_pages 1
