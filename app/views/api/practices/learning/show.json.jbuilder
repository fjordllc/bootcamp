json.(@learning, :status, :updated_at)
json.practice do
  json.submission @learning.practice.submission
  if product = @learning.practice.product(current_user)
    json.product do
      json.id @learning.practice.product(current_user).id
    end
  end
end
