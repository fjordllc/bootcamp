# frozen_string_literal: true

require 'test_helper'

class McpResourceIsolationTest < ActionDispatch::IntegrationTest
  MCP_SCOPE = 'mcp:practices:read'

  setup do
    @user = users(:mentormentaro)
    @mcp_application = create_application(mcp_client: true, scopes: MCP_SCOPE)
    @mcp_token = create_access_token(@mcp_application, @user, MCP_SCOPE)
    @legacy_application = create_application(scopes: 'read write')
    @legacy_token = create_access_token(@legacy_application, @user, 'read write')
  end

  test 'MCP access token cannot read existing user API' do
    get api_user_path(@user.id, format: :json), headers: bearer_headers(@mcp_token)

    assert_response :unauthorized
    assert_equal 'invalid_token', JSON.parse(response.body).fetch('error')
  end

  test 'MCP access token cannot create bookmarks through existing API' do
    report = reports(:report2)

    assert_no_difference('Bookmark.count') do
      post api_bookmarks_path(format: :json),
           params: { bookmarkable_id: report.id, bookmarkable_type: 'Report' },
           headers: bearer_headers(@mcp_token)
    end

    assert_response :unauthorized
    assert_equal 'invalid_token', JSON.parse(response.body).fetch('error')
  end

  test 'MCP scope is rejected even when the OAuth application lacks the MCP marker' do
    application = create_application(scopes: MCP_SCOPE)
    token = create_access_token(application, @user, MCP_SCOPE)

    get api_user_path(@user.id, format: :json), headers: bearer_headers(token)

    assert_response :unauthorized
    assert_equal 'invalid_token', JSON.parse(response.body).fetch('error')
  end

  test 'MCP-marked application is rejected even when the token has no MCP scope' do
    token = create_access_token(@mcp_application, @user, 'read')

    get api_user_path(@user.id, format: :json), headers: bearer_headers(token)

    assert_response :unauthorized
    assert_equal 'invalid_token', JSON.parse(response.body).fetch('error')
  end

  test 'ordinary OAuth token retains access to existing API reads and writes' do
    get api_user_path(@user.id, format: :json), headers: bearer_headers(@legacy_token)
    assert_response :ok

    report = reports(:report2)
    assert_difference('Bookmark.count', 1) do
      post api_bookmarks_path(format: :json),
           params: { bookmarkable_id: report.id, bookmarkable_type: 'Report' },
           headers: bearer_headers(@legacy_token)
    end
    assert_response :created
  end

  private

  def create_application(mcp_client: false, scopes: 'read write')
    Doorkeeper::Application.create!(
      name: 'Resource isolation test client',
      redirect_uri: 'https://example.com/callback',
      scopes:,
      mcp_client:
    )
  end

  def create_access_token(application, owner, scopes)
    Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: owner.id,
      scopes:,
      resource: application.mcp_client? ? 'http://www.example.com/mcp' : nil
    )
  end

  def bearer_headers(token)
    { Authorization: "Bearer #{token.token}", Accept: 'application/json' }
  end
end
