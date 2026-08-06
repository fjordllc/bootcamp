json.partial! "api/products/product", product: @product

json.body @product.body

json.practice do
  json.id @product.practice.id
  json.description @product.practice.description
end

json.comments do
  json.list @product.comments do |comment|
    json.id comment.id
    json.description comment.description
    json.created_at comment.created_at
    json.updated_at comment.updated_at
    json.user do
      json.partial! 'api/users/user', user: comment.user
    end
  end
end

json.checks do
  json.list @product.checks do |check|
    json.id check.id
    json.user do
      json.id check.user.id
      json.login_name check.user.login_name
    end
    json.created_at check.created_at
  end
end
