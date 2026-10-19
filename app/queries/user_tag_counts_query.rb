# frozen_string_literal: true

class UserTagCountsQuery < Patterns::Query
  queries User

  private

  def query
    relation.unretired.unhibernated.all_tag_counts(order: 'count desc, name asc')
  end
end
