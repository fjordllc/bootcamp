# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/registration_invitation_helper'

module Users
  class RegistrationTest < ApplicationSystemTestCase
    include RegistrationInvitationHelper

    test 'GET /users/new' do
      Capybara.using_driver(:rack_test) do
        visit '/users/new'
        assert_selector 'h1.auth-form__title', text: 'FBC参加登録'
        assert_selector 'form[name=user]'
      end
    end

    test 'GET /users/new as an adviser' do
      visit_registration_invitation 'adviser'
      assert_selector 'form[name=user]'
      assert_equal 'FBCアドバイザー参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    end

    test 'GET /users/new as a trainee' do
      visit_registration_invitation 'trainee_invoice_payment'
      assert_selector 'form[name=user]'
      assert_equal 'FBC研修生参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    end

    test 'GET /users/new as a mentor' do
      visit_registration_invitation 'mentor'
      assert_selector 'form[name=user]'
      assert_equal 'FBCメンター参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    end
  end
end
