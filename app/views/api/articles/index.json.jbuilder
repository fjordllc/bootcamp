json.articles @articles do |article|
  json.partial! 'api/articles/article', article:
end

json.total_pages @articles.total_pages
