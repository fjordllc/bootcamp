# frozen_string_literal: true

require 'test_helper'

class API::AnnouncementsTest < ActionDispatch::IntegrationTest
  fixtures :announcements

  setup do
    @announcement = announcements(:announcement1)
  end

  test 'GET /api/announcements.json' do
    get api_announcements_path(format: :json)
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    get api_announcements_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'POST /api/announcements.json' do
    post api_announcements_path(format: :json),
         params: { title: 'test', description: 'postのテストです', target: 'students', wip: false }
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    post api_announcements_path(format: :json),
         params: { title: 'test', description: 'postのテストです', target: 'students', wip: false },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created
  end

  test 'GET /api/announcements/1234.json' do
    get api_announcement_path(@announcement.id, format: :json)
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    get api_announcement_path(@announcement.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'PATCH /api/announcements/1234.json' do
    patch api_announcement_path(@announcement.id, format: :json),
          params: { title: 'test', description: 'patchのテストです', target: 'students', wip: false }
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    patch api_announcement_path(@announcement.id, format: :json),
          params: { title: 'test', description: 'patchのテストです', target: 'students', wip: false },
          headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'DELETE /api/announcements/1234.json' do
    delete api_announcement_path(@announcement.id, format: :json)
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    delete api_announcement_path(@announcement.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :no_content
  end
end
