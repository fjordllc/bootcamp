json.searchables do
  json.array! @searchables do |searchable|
    json.partial! "api/searchables/searchable", searchable: searchable
  end
end
json.total_pages @searchables.page(1).total_pages
