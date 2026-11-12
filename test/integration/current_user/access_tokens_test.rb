# frozen_string_literal: true

require 'test_helper'

class CurrentUser::AccessTokensTest < ActionDispatch::IntegrationTest
  test 'guest cannot open access tokens page' do
    get current_user_access_tokens_path

    assert_response :redirect
  end

  test 'student cannot issue access token' do
    login(users(:kimura))

    get current_user_access_tokens_path
    assert_redirected_to root_path

    assert_no_difference -> { Doorkeeper::AccessToken.count } do
      post current_user_access_tokens_path, params: { personal_access_token: { scopes: %w[write], expires_in_days: 30 } }
    end
    assert_redirected_to root_path
  end

  test 'access tokens link is shown on profile edit page only for mentor and admin' do
    login(users(:mentormentaro))
    get edit_current_user_path
    assert_select 'a[href=?]', current_user_access_tokens_path

    reset!
    login(users(:kimura))
    get edit_current_user_path
    assert_select 'a[href=?]', current_user_access_tokens_path, false
  end

  test 'mentor issues access token and updates practice with it' do
    mentor = users(:mentormentaro)
    practice = practices(:practice1)
    login(mentor)

    get new_current_user_access_token_path
    assert_response :success
    assert_select 'input[name="personal_access_token[scopes][]"][value="mentor"]'
    assert_select 'input[name="personal_access_token[scopes][]"][value="admin"]', false

    assert_difference -> { PersonalAccessToken.for_user(mentor).count }, 1 do
      post current_user_access_tokens_path, params: { personal_access_token: { scopes: %w[write mentor], expires_in_days: 30 } }
    end
    assert_response :created
    assert_equal 'no-store', response.headers['Cache-Control']

    access_token = PersonalAccessToken.for_user(mentor).first
    assert_equal %w[read write mentor], access_token.scopes.to_a
    assert_equal 30.days.to_i, access_token.expires_in
    assert_select 'input#issued_access_token[value=?]', access_token.token

    reset!
    patch api_practice_path(practice, format: :json),
          params: { practice: { description: '個人アクセストークンで更新した内容' } },
          headers: { Authorization: "Bearer #{access_token.token}" }

    assert_response :ok
    assert_equal '個人アクセストークンで更新した内容', practice.reload.description
    assert_equal mentor, practice.last_updated_user
  end

  test 'issued token is not shown again on index' do
    mentor = users(:mentormentaro)
    login(mentor)
    post current_user_access_tokens_path, params: { personal_access_token: { scopes: %w[write], expires_in_days: 90 } }
    access_token = PersonalAccessToken.for_user(mentor).first

    get current_user_access_tokens_path

    assert_response :success
    assert_select "tr#access_token_#{access_token.id}"
    assert_not_includes response.body, access_token.token
  end

  test 'mentor cannot issue access token with admin scope' do
    login(users(:mentormentaro))

    assert_no_difference -> { Doorkeeper::AccessToken.count } do
      post current_user_access_tokens_path, params: { personal_access_token: { scopes: %w[write admin], expires_in_days: 30 } }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, '指定できないスコープが含まれています。'
  end

  test 'admin can issue access token with admin scope' do
    admin = users(:komagata)
    login(admin)

    post current_user_access_tokens_path, params: { personal_access_token: { scopes: %w[admin], expires_in_days: 365 } }

    assert_response :created
    assert_equal %w[read admin], PersonalAccessToken.for_user(admin).first.scopes.to_a
  end

  test 'access token cannot be issued with unlisted expiration' do
    login(users(:mentormentaro))

    assert_no_difference -> { Doorkeeper::AccessToken.count } do
      post current_user_access_tokens_path, params: { personal_access_token: { scopes: %w[write], expires_in_days: 9999 } }
    end

    assert_response :unprocessable_entity
  end

  test 'revoked access token can no longer be used' do
    mentor = users(:mentormentaro)
    login(mentor)
    post current_user_access_tokens_path, params: { personal_access_token: { scopes: %w[write mentor], expires_in_days: 30 } }
    access_token = PersonalAccessToken.for_user(mentor).first

    delete current_user_access_token_path(access_token)

    assert_redirected_to current_user_access_tokens_path
    assert access_token.reload.revoked?
    assert_empty PersonalAccessToken.for_user(mentor)

    reset!
    patch api_practice_path(practices(:practice1), format: :json),
          params: { practice: { description: '更新されない内容' } },
          headers: { Authorization: "Bearer #{access_token.token}" }

    assert_response :unauthorized
  end

  test "mentor cannot revoke another user's access token" do
    admin = users(:komagata)
    token = PersonalAccessToken.new(user: admin, scopes: %w[write], expires_in_days: 30)
    token.save
    login(users(:mentormentaro))

    delete current_user_access_token_path(token.access_token)

    assert_response :not_found
    assert_not token.access_token.reload.revoked?
  end

  private

  def login(user)
    post user_sessions_path, params: {
      user: {
        login: user.login_name,
        password: 'testtest'
      }
    }
  end
end
