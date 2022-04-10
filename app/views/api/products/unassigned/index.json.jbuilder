json.products do
  json.array! @products do |product|
    json.partial! "api/products/product", product: product
  end
end

json.all_submitted_products do
  json.array! @all_submitted_products do |key, products|
    json.key key
    json.products do
      json.array! products do |product|
        json.partial! "api/products/product", product: product
      end
    end
  end
end
json.total_pages 1
