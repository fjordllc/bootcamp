# frozen_string_literal: true

require 'application_system_test_case'

class CompaniesTest < ApplicationSystemTestCase
  setup { login_user 'komagata', 'testtest' }

  test 'GET /companies' do
    Bootcamp::Setup.attachment
    visit '/companies'
    assert_equal '企業一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show company information' do
    Bootcamp::Setup.attachment
    visit "/companies/#{companies(:company1).id}"
    assert_equal 'Fjord Inc.の会社情報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show link to website if company has' do
    Bootcamp::Setup.attachment
    visit "/companies/#{companies(:company1).id}"
    within '.user-metas__items' do
      assert_link 'Fjord Inc.', href: 'https://fjord.jp'
    end
  end
end
