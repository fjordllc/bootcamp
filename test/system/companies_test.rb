# frozen_string_literal: true

require 'application_system_test_case'

class CompaniesTest < ApplicationSystemTestCase
  test 'GET /companies' do
    visit_with_auth '/companies', 'komagata'
    assert_equal '企業一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show company information' do
    visit_with_auth "/companies/#{companies(:company1).id}", 'komagata'
    assert_equal 'Fjord Inc.の企業情報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show link to website if company has' do
    visit_with_auth "/companies/#{companies(:company1).id}", 'komagata'
    within '.company-links' do
      assert_link '企業ページ', href: 'https://fjord.jp'
    end
  end
end
