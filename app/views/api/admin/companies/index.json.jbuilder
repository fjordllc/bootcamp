json.companies do
  json.array! @companies do |company|
    json.partial! "api/admin/companies/company", company: company
  end
end
json.total_pages @companies.total_pages
