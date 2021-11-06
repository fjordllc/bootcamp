# frozen_string_literal: true

require 'application_system_test_case'

class Company::UsersTest < ApplicationSystemTestCase
  test 'show users' do
    visit_with_auth "/companies/#{companies(:company1).id}/users", 'kimura'
    assert_equal 'Fjord Inc.所属ユーザー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show users by user category' do
    visit_with_auth "/companies/#{companies(:company2).id}/users", 'kimura'
    # デフォルトは現役生のユーザーを表示
    # Kensyu Owata は研修を終えている研修生
    assert_no_text 'Kensyu Owata'

    click_link '全員'
    assert_text 'Kensyu Owata'

    click_link '現役生'
    assert_no_text 'Kensyu Owata'
  end
end
