# frozen_string_literal: true

class UsersByAreaQuery < Patterns::Query
  queries User

  private

  def initialize(relation = User.all, area:)
    super(relation)
    @area = area
  end

  def query
    subdivision = ISO3166::Country[:JP].find_subdivision_by_name(@area)
    return relation.with_attached_avatar.where(subdivision_code: subdivision.code.to_s) if subdivision

    country = ISO3166::Country.find_country_by_any_name(@area)
    return relation.with_attached_avatar.where(country_code: country.alpha2) if country

    relation.none
  end
end
