# frozen_string_literal: true

json.array! @companies, partial: "api/users/companies/company", as: :company
