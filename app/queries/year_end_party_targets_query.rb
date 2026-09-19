# frozen_string_literal: true

class YearEndPartyTargetsQuery < Patterns::Query
  queries User

  private

  def query
    relation.where(hibernated_at: nil, retired_on: nil)
  end
end
