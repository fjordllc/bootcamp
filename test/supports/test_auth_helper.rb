# frozen_string_literal: true

module TestAuthHelper
  # include Sorcery::TestHelpers::Rails

  def visit_with_auth(url, login_name)
    logout if page.has_selector?('.test-show-menu')

    uri = URI.parse(url)
    queries = Rack::Utils.parse_nested_query(uri.query)
    queries['_login_name'] = login_name
    uri.query = queries.to_query
    visit uri.to_s
  end
end
