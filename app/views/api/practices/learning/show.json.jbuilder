json.(@learning, :status, :updated_at)
json.practice do
  json.submission @learning.practice.submission
  product = @learning.practice.learner_record.product(current_user)
  if product
    json.product do
      json.id product.id
    end
  end
end
