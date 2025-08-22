# test/integration/api/pub_sub_test.rb
# frozen_string_literal: true

require 'test_helper'

class API::PubSubTest < ActionDispatch::IntegrationTest
  test 'POST /api/pubsub returns ok' do
    payload = { message: { data: 'dummy' } }

    ProcessTranscodingNotification.stub(:call, OpenStruct.new(success?: true)) do
      post api_pubsub_path(format: :json),
           params: payload.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }

      assert_response :ok
    end
  end
end
