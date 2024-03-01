# frozen_string_literal: true

module CompaniesHelper
  def desc_ordered_companies_with_empty
    desc_ordered_companies = Company.order(created_at: :desc).to_a
    desc_ordered_companies.unshift(Company.new(name: '所属なし'))
  end

  def link_to_company_users_path(company, target)
    link_to t("target.#{target}"), company_users_path(target:, company_id: company.id), class: 'tab-nav__item-link'
  end
end
