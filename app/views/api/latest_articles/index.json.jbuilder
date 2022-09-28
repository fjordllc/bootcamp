json.latest_articles @latest_articles, partial: 'api/latest_articles/latest_article', as: :latest_article
json.total_pages @latest_articles.total_pages
