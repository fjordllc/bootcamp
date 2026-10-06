# frozen_string_literal: true

require 'test_helper'

class API::BookmarksTest < ActionDispatch::IntegrationTest
  test 'unauthenticated request cannot delete a bookmark' do
    bookmark = bookmarks(:bookmark_report)

    assert_no_difference('Bookmark.count') do
      delete api_bookmark_path(bookmark, format: :json)
    end

    assert_response :unauthorized
    assert Bookmark.exists?(bookmark.id)
  end

  %i[jwt session].each do |authentication|
    test "#{authentication} owner can delete own bookmark" do
      bookmark = bookmarks(:bookmark_report)
      headers = authenticate_user(:kimura, authentication)

      assert_difference('Bookmark.count', -1) do
        delete api_bookmark_path(bookmark, format: :json), headers:
      end

      assert_response :no_content
      assert_not Bookmark.exists?(bookmark.id)
    end

    %i[hajime komagata].each do |user|
      test "#{authentication} #{user} cannot delete another user's bookmark" do
        bookmark = bookmarks(:bookmark_report)
        headers = authenticate_user(user, authentication)

        assert_no_difference('Bookmark.count') do
          delete api_bookmark_path(bookmark, format: :json), headers:
        end

        assert_response :not_found
        assert Bookmark.exists?(bookmark.id)
      end
    end

    test "#{authentication} deletion of a missing bookmark returns not found" do
      headers = authenticate_user(:kimura, authentication)

      assert_no_difference('Bookmark.count') do
        delete api_bookmark_path(Bookmark.maximum(:id) + 1, format: :json), headers:
      end

      assert_response :not_found
    end
  end

  test 'OAuth read scope cannot delete own bookmark' do
    bookmark = bookmarks(:bookmark_report)
    headers = oauth_headers(:kimura, 'read')

    assert_no_difference('Bookmark.count') do
      delete api_bookmark_path(bookmark, format: :json), headers:
    end

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
    assert Bookmark.exists?(bookmark.id)
  end

  test 'OAuth read scope is checked before missing bookmark lookup' do
    headers = oauth_headers(:kimura, 'read')

    assert_no_difference('Bookmark.count') do
      delete api_bookmark_path(Bookmark.maximum(:id) + 1, format: :json), headers:
    end

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'OAuth write scope owner can delete own bookmark' do
    bookmark = bookmarks(:bookmark_report)
    headers = oauth_headers(:kimura, 'read write')

    assert_difference('Bookmark.count', -1) do
      delete api_bookmark_path(bookmark, format: :json), headers:
    end

    assert_response :no_content
    assert_not Bookmark.exists?(bookmark.id)
  end

  %i[hajime komagata].each do |user|
    test "OAuth write scope #{user} cannot delete another user's bookmark" do
      bookmark = bookmarks(:bookmark_report)
      headers = oauth_headers(user, 'read write')

      assert_no_difference('Bookmark.count') do
        delete api_bookmark_path(bookmark, format: :json), headers:
      end

      assert_response :not_found
      assert Bookmark.exists?(bookmark.id)
    end
  end

  test 'OAuth write scope deletion of a missing bookmark returns not found' do
    headers = oauth_headers(:kimura, 'read write')

    assert_no_difference('Bookmark.count') do
      delete api_bookmark_path(Bookmark.maximum(:id) + 1, format: :json), headers:
    end

    assert_response :not_found
  end

  private

  def authenticate_user(user, authentication)
    if authentication == :session
      sign_in(user)
      {}
    else
      token = create_token(users(user).login_name, 'testtest')
      { Authorization: "Bearer #{token}" }
    end
  end

  def oauth_headers(user, scopes)
    application = Doorkeeper::Application.create!(
      name: 'Bookmark API Test',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    token = Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: users(user).id,
      scopes:
    )
    { Authorization: "Bearer #{token.token}" }
  end
end
