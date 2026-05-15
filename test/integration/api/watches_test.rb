# frozen_string_literal: true

require 'test_helper'

class API::WatchesTest < ActionDispatch::IntegrationTest
  test 'no duplicate watch for announcement' do
    announcement = announcements(:announcement1)
    token = create_token('komagata', 'testtest')
    post api_watches_path(format: :json),
         params: {
           user_id: announcement.user_id,
           watchable_id: announcement.id,
           watchable_type: 'Announcement'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    post api_watches_path(format: :json),
         params: {
           user_id: announcement.user_id,
           watchable_id: announcement.id,
           watchable_type: 'Announcement'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unprocessable_entity
  end

  test 'no duplicate watch for product' do
    product = products(:product1)
    token = create_token('komagata', 'testtest')
    post api_watches_path(format: :json),
         params: {
           user_id: product.user_id,
           watchable_id: product.id,
           watchable_type: 'Product'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    post api_watches_path(format: :json),
         params: {
           user_id: product.user_id,
           watchable_id: product.id,
           watchable_type: 'Product'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unprocessable_entity
  end

  test 'no duplicate watch for report' do
    report = reports(:report1)
    token = create_token('komagata', 'testtest')
    post api_watches_path(format: :json),
         params: {
           user_id: report.user_id,
           watchable_id: report.id,
           watchable_type: 'Report'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    post api_watches_path(format: :json),
         params: {
           user_id: report.user_id,
           watchable_id: report.id,
           watchable_type: 'Report'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unprocessable_entity
  end

  test 'no duplicate watch for question' do
    question = questions(:question1)
    token = create_token('komagata', 'testtest')
    post api_watches_path(format: :json),
         params: {
           user_id: question.user_id,
           watchable_id: question.id,
           watchable_type: 'Question'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    post api_watches_path(format: :json),
         params: {
           user_id: question.user_id,
           watchable_id: question.id,
           watchable_type: 'Question'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unprocessable_entity
  end

  test 'no duplicate watch for page' do
    page = pages(:page1)
    token = create_token('komagata', 'testtest')
    post api_watches_path(format: :json),
         params: {
           user_id: page.user_id,
           watchable_id: page.id,
           watchable_type: 'Page'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    post api_watches_path(format: :json),
         params: {
           user_id: page.user_id,
           watchable_id: page.id,
           watchable_type: 'Page'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unprocessable_entity
  end

  test 'no duplicate watch for event' do
    event = events(:event1)
    token = create_token('komagata', 'testtest')
    post api_watches_path(format: :json),
         params: {
           user_id: event.user_id,
           watchable_id: event.id,
           watchable_type: 'Event'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    post api_watches_path(format: :json),
         params: {
           user_id: event.user_id,
           watchable_id: event.id,
           watchable_type: 'Event'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unprocessable_entity
  end

  test 'no duplicate watch for regular event' do
    regular_event = regular_events(:regular_event1)
    token = create_token('komagata', 'testtest')
    post api_watches_path(format: :json),
         params: {
           user_id: regular_event.user_id,
           watchable_id: regular_event.id,
           watchable_type: 'RegularEvent'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    post api_watches_path(format: :json),
         params: {
           user_id: regular_event.user_id,
           watchable_id: regular_event.id,
           watchable_type: 'RegularEvent'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unprocessable_entity
  end
end
