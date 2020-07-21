# frozen_string_literal: true

json.call(practice, :id, :description, :created_at, :updated_at)
json.title "[#{practice.category.name}] #{practice.title}"
