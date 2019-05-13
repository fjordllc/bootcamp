json.id @product.id
json.checks @product.checks.present?
json.check_id @product.checks.ids[0]
