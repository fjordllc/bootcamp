# frozen_string_literal: true

require 'test_helper'

class API::BookmarksTest < ActionDispatch::IntegrationTest
  test 'GET /api/bookmarks.json' do
    get api_bookmarks_path(format: :json)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get api_bookmarks_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'POST /api/bookmarks.json' do
    report = reports(:report1)
    post api_bookmarks_path(format: :json),
         params: {
           user: 'machida',
           bookmarkable: report.id,
           bookmarkable_type: 'Report'
         }
    assert_response :unauthorized

    token = create_token('machida', 'testtest')
    post api_bookmarks_path(format: :json),
         params: {
           user: 'machida',
           bookmarkable_id: report.id,
           bookmarkable_type: 'Report'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created
  end

  test 'DELETE /api/bookmarks/1234.json' do
    bookmark = bookmarks(:bookmark1)
    delete api_bookmark_path(bookmark.id, format: :json)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    delete api_bookmark_path(bookmark.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :no_content
  end

  test 'POST question' do
    question = questions(:question2)
    token = create_token('kimura', 'testtest')
    post api_bookmarks_path(format: :json),
         params: {
           user: 'kimura',
           bookmarkable_id: question.id,
           bookmarkable_type: 'Question'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created
  end

  test 'POST product' do
    product = products(:product2)
    token = create_token('kimura', 'testtest')
    post api_bookmarks_path(format: :json),
         params: {
           user: 'kimura',
           bookmarkable_id: product.id,
           bookmarkable_type: 'Product'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created
  end

  test 'POST page' do
    page = pages(:page2)
    token = create_token('kimura', 'testtest')
    post api_bookmarks_path(format: :json),
         params: {
           user: 'kimura',
           bookmarkable_id: page.id,
           bookmarkable_type: 'Page'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created
  end
end
