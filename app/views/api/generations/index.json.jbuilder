json.generations do
  json.array! @generations do |generation|
    json.partial! "api/generations/generation", generation: generation
  end
end

json.totalPages @generations.total_pages
