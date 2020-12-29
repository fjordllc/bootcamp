json.products do
  json.array! @products do |product|
    json.partial! "api/products/product", product: product
  end
end
