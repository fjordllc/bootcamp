# frozen_string_literal: true

require 'test_helper'

class API::Products::NotificationToDiscordTest < ActionDispatch::IntegrationTest
  fixtures :products

  test 'GET /api/products/notification_to_discord.json' do
    get api_products_notification_to_discord_index_path(format: :json)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get api_products_notification_to_discord_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    assert_equal 1, json['products_submitted_just_5days_count']
    assert_equal 2, json['products_submitted_just_6days_count']
    assert_equal 5, json['products_submitted_over_7days_count']
  end
end
