# frozen_string_literal: true

require 'test_helper'

class API::BooksTest < ActionDispatch::IntegrationTest
  test 'GET /api/books.json' do
    get api_books_path(format: :json)
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    get api_books_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
