# frozen_string_literal: true

require 'test_helper'

class API::TalksTest < ActionDispatch::IntegrationTest
  setup do
    @talk = talks(:talk9)
    @application = Doorkeeper::Application.create!(
      name: 'Talk authorization tests',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
  end

  test 'unauthenticated update is rejected before looking up a talk' do
    assert_no_changes -> { @talk.reload.attributes } do
      patch api_talk_path(0, format: :json), params: { talk: { action_completed: false } }
      assert_response :unauthorized
    end
  end

  %i[kimura mentormentaro advijirou hajime].each do |actor|
    test "#{actor} cannot update talk status with JWT" do
      token = create_token(users(actor).login_name, 'testtest')
      reset!

      assert_no_changes -> { @talk.reload.attributes } do
        patch api_talk_path(@talk, format: :json),
              headers: { Authorization: "Bearer #{token}" },
              params: { talk: { action_completed: false } }
        assert_response :unauthorized
      end
    end
  end

  test 'nonadmin update is rejected before looking up a talk' do
    token = create_token('mentormentaro', 'testtest')
    reset!

    assert_no_changes -> { @talk.reload.attributes } do
      patch api_talk_path(0, format: :json),
            headers: { Authorization: "Bearer #{token}" },
            params: { talk: { action_completed: false } }
      assert_response :unauthorized
    end
  end

  test 'admin can update talk status with JWT' do
    token = create_token('adminonly', 'testtest')
    reset!

    patch api_talk_path(@talk, format: :json),
          headers: { Authorization: "Bearer #{token}" },
          params: { talk: { action_completed: false } }

    assert_response :no_content
    assert_not @talk.reload.action_completed?
  end

  test 'admin can update talk status with session' do
    sign_in :adminonly

    patch api_talk_path(@talk, format: :json), params: { talk: { action_completed: false } }

    assert_response :no_content
    assert_not @talk.reload.action_completed?
  end

  test 'talk owner cannot update talk status with session' do
    sign_in :hajime

    assert_no_changes -> { @talk.reload.attributes } do
      patch api_talk_path(@talk, format: :json), params: { talk: { action_completed: false } }
      assert_response :unauthorized
    end
  end

  test 'admin cannot update talk status with read scope' do
    token = oauth_token(:adminonly, 'read')

    assert_no_changes -> { @talk.reload.attributes } do
      patch api_talk_path(@talk, format: :json),
            headers: { Authorization: "Bearer #{token.token}" },
            params: { talk: { action_completed: false } }
      assert_response :forbidden
      assert_equal 'invalid_scope', response.parsed_body['error']
    end
  end

  test 'admin can update talk status with write scope' do
    token = oauth_token(:adminonly, 'read write')

    patch api_talk_path(@talk, format: :json),
          headers: { Authorization: "Bearer #{token.token}" },
          params: { talk: { action_completed: false } }

    assert_response :no_content
    assert_not @talk.reload.action_completed?
  end

  %i[kimura mentormentaro advijirou hajime].each do |actor|
    test "#{actor} cannot update talk status with write scope" do
      token = oauth_token(actor, 'read write')

      assert_no_changes -> { @talk.reload.attributes } do
        patch api_talk_path(@talk, format: :json),
              headers: { Authorization: "Bearer #{token.token}" },
              params: { talk: { action_completed: false } }
        assert_response :unauthorized
      end
    end
  end

  private

  def oauth_token(actor, scopes)
    Doorkeeper::AccessToken.create!(application: @application, resource_owner_id: users(actor).id, scopes:)
  end
end
