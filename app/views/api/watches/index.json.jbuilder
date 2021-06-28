json.watches do
  json.array! @watches do |watch|
    json.partial! 'api/watches/watch', watch: watch
  end
end

json.totalPages @watches.total_pages
