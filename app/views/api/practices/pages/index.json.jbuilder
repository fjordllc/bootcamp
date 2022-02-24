json.pages @pages do |page|
  json.partial! 'api/pages/page', page: page
end

json.totalPages @pages.total_pages
