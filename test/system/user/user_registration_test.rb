# frozen_string_literal: true

require 'application_system_test_case'

class UserRegistrationTest < ApplicationSystemTestCase
  test 'GET /users/new' do
    visit '/users/new'
    assert_equal 'FBC参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /users/new as an adviser' do
    visit '/users/new?role=adviser'
    assert_equal 'FBCアドバイザー参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /users/new as a trainee' do
    visit '/users/new?role=trainee_invoice_payment'
    assert_equal 'FBC研修生参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /users/new as a mentor' do
    visit '/users/new?role=mentor'
    assert_equal 'FBCメンター参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
