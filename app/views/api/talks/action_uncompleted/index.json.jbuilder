json.partial! 'api/talks/talks', talks: @talks
json.totalPages @talks.total_pages if @talks.respond_to? :total_pages
