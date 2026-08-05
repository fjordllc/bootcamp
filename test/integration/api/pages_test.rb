# frozen_string_literal: true

require 'test_helper'

class API::PagesTest < ActionDispatch::IntegrationTest
  setup do
    @application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
  end

  test 'PATCH /api/pages/1234.json updates content' do
    page = pages(:page1)
    user = users(:komagata)
    token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: user.id,
      scopes: 'read write'
    )

    patch api_page_path(page, format: :json),
          params: { page: { body: 'APIから更新した本文' } },
          headers: { Authorization: "Bearer #{token.token}" }

    assert_response :ok
    assert_equal 'APIから更新した本文', page.reload.body
    assert_equal user, page.last_updated_user
  end

  test 'PATCH /api/pages/1234.json requires write scope to update content' do
    page = pages(:page1)
    token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:komagata).id,
      scopes: 'read'
    )

    patch api_page_path(page, format: :json),
          params: { page: { body: '更新されない本文' } },
          headers: { Authorization: "Bearer #{token.token}" }

    assert_response :forbidden
    assert_not_equal '更新されない本文', page.reload.body
  end

  test 'PATCH /api/pages/1234.json requires OAuth token to update content' do
    page = pages(:page1)
    token = create_token('komagata', 'testtest')

    patch api_page_path(page, format: :json),
          params: { page: { body: '更新されない本文' } },
          headers: { Authorization: "Bearer #{token}" }

    assert_response :unauthorized
    assert_not_equal '更新されない本文', page.reload.body
  end
end
