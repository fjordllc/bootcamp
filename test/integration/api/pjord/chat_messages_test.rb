# frozen_string_literal: true

require 'test_helper'

class API::Pjord::ChatMessagesTest < ActionDispatch::IntegrationTest
  test 'student can create a Pjord chat message' do
    login(users(:hajime))

    Pjord::ChatAgent.stub(:reply, '関連するDocを確認してみましょう。') do
      assert_difference('PjordChatSession.count', 1) do
        assert_difference('PjordChatMessage.count', 2) do
          post api_pjord_chat_messages_path(format: :json), params: { message: '次は何をすればいいですか？' }
        end
      end
    end

    assert_response :created
    assert_equal 'user', response.parsed_body.dig('user_message', 'role')
    assert_equal '次は何をすればいいですか？', response.parsed_body.dig('user_message', 'body')
    assert_equal 'assistant', response.parsed_body.dig('assistant_message', 'role')
    assert_equal '関連するDocを確認してみましょう。', response.parsed_body.dig('assistant_message', 'body')
  end

  test 'student can get saved Pjord chat messages' do
    user = users(:hajime)
    session = PjordChatSession.create!(user:)
    session.messages.create!(role: 'user', body: '相談です')
    session.messages.create!(role: 'assistant', body: '回答です')
    login(user)

    get api_pjord_chat_messages_path(format: :json)

    assert_response :success
    roles = response.parsed_body['messages'].map { |message| message['role'] }
    bodies = response.parsed_body['messages'].map { |message| message['body'] }
    assert_equal %w[user assistant], roles
    assert_equal %w[相談です 回答です], bodies
  end

  test 'student gets empty messages without creating a session' do
    user = users(:hajime)
    login(user)

    assert_no_difference('PjordChatSession.count') do
      get api_pjord_chat_messages_path(format: :json)
    end

    assert_response :success
    assert_empty response.parsed_body['messages']
  end

  test 'returns fallback assistant message when Pjord chat agent fails' do
    login(users(:hajime))

    Pjord::ChatAgent.stub(:reply, ->(**) { raise StandardError, 'LLM error' }) do
      assert_difference('PjordChatMessage.count', 2) do
        post api_pjord_chat_messages_path(format: :json), params: { message: '相談です' }
      end
    end

    assert_response :service_unavailable
    assert_equal 'user', response.parsed_body.dig('user_message', 'role')
    assert_equal 'assistant', response.parsed_body.dig('assistant_message', 'role')
    assert_equal 'すみません、今はうまく回答できませんでした。時間をおいてもう一度試すか、メンターに相談してください。',
                 response.parsed_body.dig('assistant_message', 'body')
  end

  test 'returns fallback assistant message when Pjord chat agent returns blank response' do
    login(users(:hajime))

    Pjord::ChatAgent.stub(:reply, ' ') do
      assert_difference('PjordChatMessage.count', 2) do
        post api_pjord_chat_messages_path(format: :json), params: { message: '相談です' }
      end
    end

    assert_response :service_unavailable
    assert_equal 'user', response.parsed_body.dig('user_message', 'role')
    assert_equal 'assistant', response.parsed_body.dig('assistant_message', 'role')
    assert_equal 'すみません、今はうまく回答できませんでした。時間をおいてもう一度試すか、メンターに相談してください。',
                 response.parsed_body.dig('assistant_message', 'body')
  end

  test 'mentor cannot use Pjord chat' do
    login(users(:mentormentaro))

    assert_no_difference('PjordChatMessage.count') do
      post api_pjord_chat_messages_path(format: :json), params: { message: '相談です' }
    end

    assert_response :forbidden
  end

  test 'admin cannot use Pjord chat' do
    login(users(:komagata))

    assert_no_difference('PjordChatMessage.count') do
      post api_pjord_chat_messages_path(format: :json), params: { message: '相談です' }
    end

    assert_response :forbidden
  end

  test 'requires login' do
    get api_pjord_chat_messages_path(format: :json)

    assert_response :unauthorized
  end

  test 'read-only API token cannot create a Pjord chat message' do
    token = create_doorkeeper_token(users(:hajime), scopes: 'read')

    assert_no_difference('PjordChatMessage.count') do
      post api_pjord_chat_messages_path(format: :json),
           headers: { Authorization: "Bearer #{token.token}" },
           params: { message: '相談です' }
    end

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'read-only API token can get Pjord chat messages' do
    user = users(:hajime)
    session = PjordChatSession.create!(user:)
    session.messages.create!(role: 'user', body: 'API相談です')
    token = create_doorkeeper_token(user, scopes: 'read')

    get api_pjord_chat_messages_path(format: :json), headers: { Authorization: "Bearer #{token.token}" }

    assert_response :success
    bodies = response.parsed_body['messages'].map { |message| message['body'] }
    assert_equal ['API相談です'], bodies
  end

  test 'write API token can create a Pjord chat message' do
    token = create_doorkeeper_token(users(:hajime), scopes: 'read write')

    Pjord::ChatAgent.stub(:reply, 'APIからも回答できます。') do
      assert_difference('PjordChatMessage.count', 2) do
        post api_pjord_chat_messages_path(format: :json),
             headers: { Authorization: "Bearer #{token.token}" },
             params: { message: 'APIから相談です' }
      end
    end

    assert_response :created
    assert_equal 'APIからも回答できます。', response.parsed_body.dig('assistant_message', 'body')
  end

  test 'requires message body' do
    login(users(:hajime))

    assert_no_difference('PjordChatMessage.count') do
      post api_pjord_chat_messages_path(format: :json), params: { message: ' ' }
    end

    assert_response :bad_request
    assert_equal '相談内容を入力してください。', response.parsed_body['message']
  end

  test 'rejects too long message body' do
    login(users(:hajime))

    assert_no_difference('PjordChatMessage.count') do
      post api_pjord_chat_messages_path(format: :json), params: { message: 'a' * 2_001 }
    end

    assert_response :bad_request
    assert_equal '相談内容は2000文字以内で入力してください。', response.parsed_body['message']
  end

  test 'rate limits frequent messages' do
    user = users(:hajime)
    session = PjordChatSession.create!(user:)
    20.times { session.messages.create!(role: 'user', body: '相談です') }
    login(user)

    assert_no_difference('PjordChatMessage.count') do
      post api_pjord_chat_messages_path(format: :json), params: { message: 'もう一度相談です' }
    end

    assert_response :too_many_requests
  end

  private

  def login(user)
    post user_sessions_path, params: {
      user: {
        login: user.login_name,
        password: 'testtest'
      }
    }
  end

  def create_doorkeeper_token(user, scopes:)
    application = Doorkeeper::Application.create!(
      name: 'Pjord Chat Test',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: user.id,
      scopes:
    )
  end
end
