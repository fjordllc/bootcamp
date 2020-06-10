# frozen_string_literal: true

module CompanyHelper
  def all_companies_with_empty
    Company.all.to_a.unshift(Company.new(name: "所属なし"))
  end
end
