# frozen_string_literal: true

module QueryHelper
  def visit_with_query(url, query_hash)
    uri = URI.parse(url)
    uri.query = query_hash.to_query
    visit uri.to_s
  end
end
