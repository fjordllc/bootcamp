# frozen_string_literal: true

module TestAuthHelper
  def visit_with_auth(url, login_name)
    uri = URI.parse(url)
    queries = Rack::Utils.parse_nested_query(uri.query)
    queries['_login_name'] = login_name
    uri.query = queries.to_query
    visit uri.to_s
  end
end
