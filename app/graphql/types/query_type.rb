module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.
    field :courses, Types::CourseType.connection_type, null: false
    def courses
      Course.order(:created_at)
    end

    field :companies, Types::CompanyType.connection_type, null: false
    def companies
      Company.order(:created_at)
    end
  end
end
