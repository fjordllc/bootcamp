# frozen_string_literal: true

module CompaniesHelper
  def desc_ordered_companies_with_empty
    desc_ordered_companies = Company.order(created_at: :desc).to_a
    desc_ordered_companies.unshift(Company.new(name: '所属なし'))
  end

  def link_to_company_users_path(company, target:)
    target_allowlist = %w[advisers students_and_trainees admins mentor]
    link_to_if(target_allowlist.include?(target),
               company.users.unretired.send(target).size,
               company_users_path(target: target.singularize, company_id: company.id),
               class: 'card-counts__item-value-link')
  end
end
