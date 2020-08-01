# frozen_string_literal: true

json.call(practice, :id, :title, :description, :created_at, :updated_at)
json.option "[#{practice.category.name}] #{practice.title}"
