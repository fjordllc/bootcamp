json.featuredEntries do
  json.array! @featured_entries do |featured_entry|
    json.partial! "api/featured_entries/featured_entry", featured_entry: featured_entry
  end
end
json.totalPages @featured_entries.total_pages if @featured_entries.respond_to?(:total_pages)
