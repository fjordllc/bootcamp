# frozen_string_literal: true

module CompaniesHelper
  def all_companies_with_empty
    Company.all.to_a.unshift(Company.new(name: '所属なし'))
  end

  def link_to_company_users_path(company, target:)
    link_to company.users.unretired.send(target).size, company_users_path(target: target.singularize, company_id: company.id),
            class: 'card-counts__item-value-link'
  end
end
