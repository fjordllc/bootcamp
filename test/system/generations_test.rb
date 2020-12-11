# frozen_string_literal: true

require 'application_system_test_case'

class GenerationsTest < ApplicationSystemTestCase
  test 'show same generation users' do
    login_user 'kimura', 'testtest'
    visit generation_path(users(:kimura).generation)
    assert_equal "#{users(:kimura).generation}期のユーザー一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
    assert_text users(:kimura).name
    assert_text users(:komagata).name
  end

  test 'show no same generation users' do
    login_user 'kimura', 'testtest'
    visit generation_path(0)
    assert_text '0期のユーザー一覧はありません'
  end

  test 'show generations' do
    login_user 'kimura', 'testtest'
    visit generations_path
    assert_text 'ユーザー一覧'
    assert_link "#{users(:kimura).generation}期生"
    assert_text '2014年01月01日 ~ 2014年03月31日'
  end
end
