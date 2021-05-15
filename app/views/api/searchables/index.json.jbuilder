json.searchables do
  json.array! @searchables do |searchable|
    json.partial! "api/searchables/searchable", searchable: searchable
  end
end
json.total_pages @searchables.total_pages
