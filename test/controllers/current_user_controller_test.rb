# frozen_string_literal: true

require 'test_helper'

class CurrentUserControllerTest < ActionDispatch::IntegrationTest
  %i[kimura senpai kensyu mentormentaro].each do |fixture|
    test "#{fixture} cannot change adviser trainee or company through self-profile update" do
      user = users(fixture)
      original_attributes = user.attributes.slice('adviser', 'trainee', 'company_id')
      sign_in user

      patch current_user_path, params: {
        user: {
          adviser: !user.adviser?,
          trainee: !user.trainee?,
          company_id: companies(:company3).id,
          description: '自己紹介を更新しました。'
        }
      }

      assert_redirected_to user_path(user)
      assert_equal original_attributes, user.reload.attributes.slice('adviser', 'trainee', 'company_id')
      assert_equal '自己紹介を更新しました。', user.description
    end
  end

  test 'adviser cannot remove company through self-profile update' do
    user = users(:senpai)
    original_company_id = user.company_id
    sign_in user

    patch current_user_path, params: { user: { company_id: '', description: '所属企業は変更しません。' } }

    assert_redirected_to user_path(user)
    assert_equal original_company_id, user.reload.company_id
    assert_equal '所属企業は変更しません。', user.description
  end

  test 'graduate cannot set company through self-profile update' do
    user = users(:sotugyou)
    user.update!(job: 'office_worker')
    sign_in user

    patch current_user_path, params: { user: { company_id: companies(:company3).id } }

    assert_redirected_to user_path(user)
    assert_nil user.reload.company_id
  end

  test 'student can update ordinary self-profile fields' do
    user = users(:kimura)
    sign_in user

    patch current_user_path, params: { user: { description: '自己紹介だけを更新しました。' } }

    assert_redirected_to user_path(user)
    assert_equal '自己紹介だけを更新しました。', user.reload.description
  end

  test 'trainee can still update training end date' do
    user = users(:kensyu)
    training_ends_on = Date.current.next_year
    sign_in user

    patch current_user_path, params: { user: { training_ends_on: } }

    assert_redirected_to user_path(user)
    assert_equal training_ends_on, user.reload.training_ends_on
  end

  test 'administrator can set adviser trainee and company through self-profile update' do
    user = users(:komagata)
    company = companies(:company3)
    sign_in user

    patch current_user_path, params: { user: { adviser: true, trainee: true, company_id: company.id } }

    assert_redirected_to user_path(user)
    assert_predicate user.reload, :adviser?
    assert_predicate user, :trainee?
    assert_equal company.id, user.company_id
  end

  test 'administrator can remove adviser trainee and company through self-profile update' do
    user = users(:komagata)
    user.update!(adviser: true, trainee: true)
    sign_in user

    patch current_user_path, params: { user: { adviser: false, trainee: false, company_id: '' } }

    assert_redirected_to user_path(user)
    assert_not_predicate user.reload, :adviser?
    assert_not_predicate user, :trainee?
    assert_nil user.company_id
  end

  %i[kimura senpai kensyu mentormentaro sotugyou].each do |fixture|
    test "#{fixture} cannot select company on self-profile form" do
      sign_in users(fixture)

      get edit_current_user_path

      assert_response :success
      assert_select 'select[name="user[company_id]"]', count: 0
    end
  end

  test 'trainee can see existing company on self-profile form' do
    user = users(:kensyu)
    sign_in user

    get edit_current_user_path

    assert_response :success
    assert_select '.js-training-info-block', text: /#{Regexp.escape(user.company.name)}/
    assert_select 'input[name="user[training_ends_on]"]'
  end

  test 'administrator can select company on self-profile form' do
    sign_in users(:komagata)

    get edit_current_user_path

    assert_response :success
    assert_select 'select[name="user[company_id]"]'
  end

  test 'administrator can select company when editing another user' do
    sign_in users(:komagata)

    get edit_admin_user_path(users(:kensyu))

    assert_response :success
    assert_select 'select[name="user[company_id]"]'
  end

  test 'invited adviser signup retains company selection' do
    company = companies(:company2)
    token = invitation_token('adviser', company)

    get new_user_path(role: 'adviser', company_id: company.id, token:)

    assert_response :success
    assert_select "select[name='user[company_id]'] option[selected][value='#{company.id}']"
  end

  test 'invited trainee signup retains company selection' do
    company = companies(:company2)
    token = invitation_token('trainee_invoice_payment', company)

    get new_user_path(role: 'trainee_invoice_payment', company_id: company.id, token:)

    assert_response :success
    assert_select "select[name='user[company_id]'] option[selected][value='#{company.id}']"
  end

  private

  def invitation_token(role, company)
    Rails.application.message_verifier(:registration_invitation).generate(
      { 'role' => role, 'company_id' => company.id.to_s },
      purpose: :registration_invitation, expires_in: 30.days
    )
  end
end
