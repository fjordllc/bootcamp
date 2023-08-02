# frozen_string_literal: true

require 'test_helper'

class API::GithubContributionsTest < ActionDispatch::IntegrationTest
  test 'GET /api/github_contributions/:id' do
    get api_github_contribution_path id: 'test'
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    get api_github_contribution_path(id: 'hatsuno', format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
