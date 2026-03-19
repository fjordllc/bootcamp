# frozen_string_literal: true

require 'test_helper'

class PjordTest < ActiveSupport::TestCase
  test '.user returns pjord user' do
    assert_equal 'pjord', Pjord.user.login_name
  end

  test '.respond returns a response' do
    stub_llm_response('テストの回答です。') do
      response = Pjord.respond(message: 'Rubyの配列について教えて')
      assert_equal 'テストの回答です。', response
    end
  end

  test '.respond returns nil on error' do
    stub_llm_error do
      response = Pjord.respond(message: 'test')
      assert_nil response
    end
  end

  private

  def stub_llm_response(text)
    mock_content = Minitest::Mock.new
    mock_content.expect(:content, text)

    mock_chat = Minitest::Mock.new
    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:ask, mock_content, [String])

    RubyLLM.stub(:chat, mock_chat) do
      yield
    end
  end

  def stub_llm_error
    RubyLLM.stub(:chat, ->(*) { raise StandardError, 'API error' }) do
      yield
    end
  end
end
