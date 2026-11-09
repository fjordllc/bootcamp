# frozen_string_literal: true

require 'test_helper'

class API::AnnouncementEventAuthorizationTest < ActionDispatch::IntegrationTest
  setup { travel_to Time.zone.local(2026, 11, 7, 12) }
  teardown { travel_back }

  %w[announcements events].each do |resource|
    test "#{resource} rejects unauthenticated reads before validating parameters" do
      get "/api/#{resource}", params: { page: 'invalid' }
      assert_response :unauthorized
    end

    test "#{resource} accepts active sessions and JWTs" do
      sign_in(:kimura)
      get "/api/#{resource}"
      assert_response :ok
      sign_out
      token = create_token('kimura', 'testtest')
      get "/api/#{resource}", headers: { Authorization: "Bearer #{token}" }
      assert_response :ok
    end

    test "#{resource} accepts ordinary OAuth read scope and rejects write-only scope" do
      get "/api/#{resource}", headers: oauth_headers
      assert_response :ok
      get "/api/#{resource}", headers: oauth_headers(scopes: 'write')
      assert_response :forbidden
    end

    test "#{resource} rejects inactive session and OAuth owners" do
      sign_in(:kimura)
      headers = oauth_headers
      [{ hibernated_at: Time.current }, { training_completed_at: Time.current }, { retired_on: Date.current }].each do |attributes|
        users(:kimura).update!(attributes)
        get "/api/#{resource}"
        assert_response :unauthorized
        get "/api/#{resource}", headers: headers
        assert_response :unauthorized
        users(:kimura).update!(hibernated_at: nil, training_completed_at: nil, retired_on: nil)
      end
    end

    test "#{resource} rejects an inactive JWT owner" do
      token = create_token('kimura', 'testtest')
      users(:kimura).update!(hibernated_at: Time.current)
      get "/api/#{resource}", headers: { Authorization: "Bearer #{token}" }
      assert_response :unauthorized
    end

    test "#{resource} rejects MCP scope and MCP applications even with an active session" do
      sign_in(:kimura)
      [{ scopes: 'mcp:practices:read' }, { mcp_client: true }].each do |options|
        get "/api/#{resource}", headers: oauth_headers(**options)
        assert_response :unauthorized
        assert_equal 'invalid_token', response.parsed_body.fetch('error')
      end
    end

    test "#{resource} has no show or write API routes" do
      sign_in(:kimura)
      assert_no_difference(['Announcement.count', 'Event.count', 'RegularEvent.count', 'Footprint.count']) do
        get "/api/#{resource}/1.json"
        assert_response :not_found
        %i[post put patch delete].each do |method|
          public_send(method, "/api/#{resource}.json", params: { title: '書き込まない' })
          assert_response :not_found
          public_send(method, "/api/#{resource}/1.json", params: { title: '書き込まない' })
          assert_response :not_found
        end
      end
    end
  end

  private

  def oauth_headers(scopes: 'read', mcp_client: false)
    application = Doorkeeper::Application.create!(
      name: 'Read-only lists test', redirect_uri: 'https://example.com/callback', scopes:, mcp_client:
    )
    token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: users(:kimura).id, scopes:)
    { Authorization: "Bearer #{token.token}" }
  end
end
