# frozen_string_literal: true

module CompaniesHelper
  def desc_ordered_companies_with_empty
    desc_ordered_companies = Company.order(created_at: :desc).to_a
    desc_ordered_companies.unshift(Company.new(name: '所属なし'))
  end
end
