json.pages do
  json.array! @pages do |page|
    json.partial! "api/pages/page", page: page
  end
end
json.total_pages @pages.page(1).total_pages
json.all_tags @tags
