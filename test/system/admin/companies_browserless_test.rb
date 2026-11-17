# frozen_string_literal: true

require 'browserless_system_test_case'

class Admin::CompaniesBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing companies' do
    visit_with_auth '/admin/companies', 'komagata'
    assert_equal '企業一覧 | FBC', title
    assert has_link?(companies(:newest_company).name, href: company_path(companies(:newest_company)))
  end
end
