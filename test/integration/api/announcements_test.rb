# frozen_string_literal: true

require 'test_helper'

class API::AnnouncementsTest < ActionDispatch::IntegrationTest
  fixtures :announcements

  setup do
    @announcement = announcements(:announcement1)
    @my_announcement = announcements(:announcement4)
  end

  test 'GET /api/announcements.json' do
    get api_announcements_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_announcements_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'POST /api/announcements.json' do
    post api_announcements_path(format: :json),
         params: {
           announcement: {
             title: 'test',
             description: 'postのテストです'
           }
         }
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    post api_announcements_path(format: :json),
         params: {
           announcement: {
             title: 'test',
             description: 'postのテストです'
           }
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created
  end

  test 'GET /api/announcements/1234.json' do
    get api_announcement_path(@announcement.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_announcement_path(@announcement.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'PATCH /api/announcements/1234.json' do
    patch api_announcement_path(@my_announcement.id, format: :json),
          params: {
            announcement: {
              title: 'test',
              description: 'patchのテストです'
            }
          }
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    patch api_announcement_path(@my_announcement.id, format: :json),
          params: {
            announcement: {
              title: 'test',
              description: 'patchのテストです'
            }
          },
          headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :bad_request

    token = create_token('komagata', 'testtest')
    patch api_announcement_path(@my_announcement.id, format: :json),
          params: {
            announcement: {
              title: 'test',
              description: 'patchのテストです'
            }
          },
          headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'DELETE /api/announcements/1234.json' do
    delete api_announcement_path(@my_announcement.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    delete api_announcement_path(@announcement.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    delete api_announcement_path(@announcement.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :no_content
  end

  test 'users except admin cannot publish an announcement when new' do
    token = create_token('kimura', 'testtest')
    post api_announcements_path(format: :json),
         params: {
           announcement: {
             title: 'test',
             description: 'postのテストです'
           }
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created
    assert Announcement.last.wip

    token = create_token('komagata', 'testtest')
    post api_announcements_path(format: :json),
         params: {
           announcement: {
             title: 'test',
             description: 'postのテストです',
             wip: false
           }
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created
    assert_not Announcement.last.wip
  end

  test 'users except admin cannot publish an announcement when edit' do
    token = create_token('kimura', 'testtest')
    patch api_announcement_path(@my_announcement.id, format: :json),
          params: {
            announcement: {
              title: 'test',
              description: 'patchのテストです',
              wip: false
            }
          },
          headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :bad_request

    token = create_token('komagata', 'testtest')
    patch api_announcement_path(@my_announcement.id, format: :json),
          params: {
            announcement: {
              title: 'test',
              description: 'patchのテストです',
              wip: false
            }
          },
          headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
