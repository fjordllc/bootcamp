require "test_helper"
require "ostruct"

class API::PubSubControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payload = { message: { data: Base64.encode64("dummy data") } }

    API::PubSubController.prepend(Module.new do
      private
      def valid_pubsub_token?(_token)
        true
      end
    end)
  end

  test "returns 200 when ProcessTranscodingNotification succeeds" do
    ProcessTranscodingNotification.stub :call, OpenStruct.new(success?: true) do
      post api_pubsub_path(format: :json),
           params: @payload.to_json,
           headers: { "CONTENT_TYPE" => "application/json", "Authorization" => "Bearer dummy" }

      assert_response :ok
    end
  end

  test "returns 500 when ProcessTranscodingNotification fails and retryable" do
    ProcessTranscodingNotification.stub :call, OpenStruct.new(success?: false, retryable: true, error: "fail") do
      post api_pubsub_path(format: :json),
           params: @payload.to_json,
           headers: { "CONTENT_TYPE" => "application/json", "Authorization" => "Bearer dummy" }

      assert_response :internal_server_error
    end
  end

  test "returns 200 when ProcessTranscodingNotification fails but not retryable" do
    ProcessTranscodingNotification.stub :call, OpenStruct.new(success?: false, retryable: false, error: "fail") do
      post api_pubsub_path(format: :json),
           params: @payload.to_json,
           headers: { "CONTENT_TYPE" => "application/json", "Authorization" => "Bearer dummy" }

      assert_response :ok
    end
  end
end
