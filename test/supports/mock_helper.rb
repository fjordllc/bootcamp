# frozen_string_literal: true

module MockHelper
  def mock_openai_chat_completion(content: 'Test AI answer for the question')
    stub_request(:post, 'https://api.openai.com/v1/chat/completions')
      .to_return(
        status: 200,
        body: {
          choices: [{
            message: {
              content:
            }
          }]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
