# frozen_string_literal: true

module MockHelper
  def mock_openai_chat_completion(content: 'Test AI answer for the question')
    stub_request(:post, 'https://api.openai.com/v1/chat/completions')
      .to_return(
        status: 200,
        body: {
          id: 'chatcmpl-test',
          object: 'chat.completion',
          model: 'gpt-5-mini',
          choices: [{
            index: 0,
            message: { role: 'assistant', content: },
            finish_reason: 'stop'
          }],
          usage: { prompt_tokens: 10, completion_tokens: 20, total_tokens: 30 }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
