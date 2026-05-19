# frozen_string_literal: true

require 'test_helper'

class API::SearchablesTest < ActionDispatch::IntegrationTest
  test 'GET /api/searchables.json requires authentication' do
    get api_searchables_path(format: :json), params: { word: '作業' }

    assert_response :unauthorized
  end

  test 'GET /api/searchables.json searches by keyword' do
    token = create_token('kimura', 'testtest')

    get api_searchables_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" },
        params: { word: '作業', document_type: 'report', mode: 'keyword' }

    assert_response :ok
    searchables = response.parsed_body['searchables']
    assert searchables.any?
    assert(searchables.all? { |searchable| searchable['type'] == 'report' })
    assert_includes searchables.first.keys, 'title'
    assert_includes searchables.first.keys, 'content'
    assert_includes searchables.first.keys, 'url'
    assert_includes searchables.first.keys, 'user'
    assert_includes searchables.first.keys, 'updated_at'
  end

  test 'GET /api/searchables.json filters by only_me' do
    token = create_token('komagata', 'testtest')

    get api_searchables_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" },
        params: { word: '作業', document_type: 'report', only_me: true }

    assert_response :ok
    assert response.parsed_body['searchables'].any?
    assert(response.parsed_body['searchables'].all? { |searchable| searchable.dig('user', 'id') == users(:komagata).id })
  end

  test 'GET /api/searchables.json searches by semantic mode' do
    token = create_token('kimura', 'testtest')

    report = reports(:report1)
    semantic_searcher = Object.new
    semantic_searcher.define_singleton_method(:search) { |*| [report] }

    SmartSearch::SemanticSearcher.stub(:new, semantic_searcher) do
      get api_searchables_path(format: :json),
          headers: { 'Authorization' => "Bearer #{token}" },
          params: { word: '作業', document_type: 'report', mode: 'semantic' }
    end

    assert_response :ok
    assert_equal [reports(:report1).id], response.parsed_body['searchables'].pluck('id')
  end

  test 'GET /api/searchables.json returns bad request with invalid document_type' do
    token = create_token('kimura', 'testtest')

    get api_searchables_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" },
        params: { word: '作業', document_type: 'unknown' }

    assert_response :bad_request
    assert_match 'Invalid document_type', response.parsed_body['message']
  end
end
