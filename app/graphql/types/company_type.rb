# frozen_string_literal: true

module Types
  class CompanyType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :description, String
    field :website, String
    field :created_at, GraphQL::Types::ISO8601DateTime
    field :updated_at, GraphQL::Types::ISO8601DateTime
    field :tos, String
    field :blog_url, String
  end
end
