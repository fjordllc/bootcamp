# frozen_string_literal: true

require 'test_helper'

class API::Users::MembershipsTest < ActionDispatch::IntegrationTest
  INACTIVE_ATTRIBUTES = %i[hibernated_at training_completed_at retired_on].freeze

  setup do
    @application = Doorkeeper::Application.create!(name: 'Membership test', redirect_uri: 'https://example.invalid/callback', scopes: 'read')
    @user = users(:kimura)
  end

  test 'returns an active membership for a user who can log in' do
    get api_user_membership_path(@user, format: :json), headers: bearer_headers(read_token(users(:mentormentaro)))

    assert_response :ok
    assert_equal({ 'id' => @user.id, 'login_name' => 'kimura', 'active' => true }, response.parsed_body)
  end

  INACTIVE_ATTRIBUTES.each do |attribute|
    test "returns an inactive membership for a user with #{attribute}" do
      @user.update!(attribute => Time.current)

      get api_user_membership_path(@user, format: :json), headers: bearer_headers(read_token(users(:komagata)))

      assert_response :ok
      assert_equal({ 'id' => @user.id, 'login_name' => 'kimura', 'active' => false }, response.parsed_body)
    end
  end

  test 'returns active memberships for graduates, advisers and mentors who can log in' do
    %i[sotugyou advijirou mentormentaro].each do |name|
      user = users(name)
      get api_user_membership_path(user, format: :json), headers: bearer_headers(read_token(users(:komagata)))

      assert_response :ok
      assert_equal({ 'id' => user.id, 'login_name' => user.login_name, 'active' => true }, response.parsed_body)
    end
  end

  test 'allows a mentor authenticated with a JWT' do
    get api_user_membership_path(@user, format: :json), headers: bearer_headers(create_token('mentormentaro', 'testtest'))

    assert_response :ok
    assert_equal({ 'id' => @user.id, 'login_name' => 'kimura', 'active' => true }, response.parsed_body)
  end

  test 'forbids students, graduates and advisers from reading memberships including their own' do
    %i[hajime sotugyou advijirou].each do |name|
      caller = users(name)
      [@user, caller].each do |target|
        get api_user_membership_path(target, format: :json), headers: bearer_headers(read_token(caller))

        assert_response :forbidden, name
        assert_equal({ 'message' => '権限がありません。' }, response.parsed_body)
      end
    end
  end

  test 'does not reveal whether a user exists to callers without permission' do
    get api_user_membership_path(0, format: :json), headers: bearer_headers(read_token(users(:hajime)))

    assert_response :forbidden
  end

  test 'forbids an OAuth token without the read scope even when its owner is a mentor' do
    application = Doorkeeper::Application.create!(name: 'Write only test', redirect_uri: 'https://example.invalid/callback', scopes: 'write')
    token = Doorkeeper::AccessToken.create!(application_id: application.id, resource_owner_id: users(:mentormentaro).id, scopes: 'write').token

    get api_user_membership_path(@user, format: :json), headers: bearer_headers(token)

    assert_response :forbidden
  end

  test 'returns not found for a missing user' do
    get api_user_membership_path(0, format: :json), headers: bearer_headers(read_token(users(:mentormentaro)))

    assert_response :not_found
    assert_equal({ 'message' => 'ユーザーが見つかりません。' }, response.parsed_body)
  end

  test 'rejects requests without credentials' do
    get api_user_membership_path(@user, format: :json)

    assert_response :unauthorized
  end

  INACTIVE_ATTRIBUTES.each do |attribute|
    test "rejects a token whose owner has #{attribute}" do
      mentor = users(:mentormentaro)
      token = read_token(mentor)
      mentor.update!(attribute => Time.current)

      get api_user_membership_path(@user, format: :json), headers: bearer_headers(token)

      assert_response :unauthorized
    end
  end

  private

  def read_token(owner)
    Doorkeeper::AccessToken.create!(application_id: @application.id, resource_owner_id: owner.id, scopes: 'read').token
  end

  def bearer_headers(token)
    { Authorization: "Bearer #{token}", Accept: 'application/json' }
  end
end
