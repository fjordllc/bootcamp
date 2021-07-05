json.bookmarks do
  json.array! @bookmarks do |bookmark|
    json.partial! "api/bookmarks/bookmark", bookmark: bookmark
  end
end
json.totalPages @bookmarks.total_pages if @bookmarks.respond_to?(:total_pages)
