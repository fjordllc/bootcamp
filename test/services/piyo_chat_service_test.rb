# frozen_string_literal: true

require 'test_helper'

class PiyoChatServiceTest < ActiveSupport::TestCase
  test 'respond returns assistant text' do
    section = textbook_sections(:section_variables)
    user = users(:hatsuno)

    mock_result = OpenStruct.new(content: 'テスト回答です')
    mock_chat = Object.new
    mock_chat.define_singleton_method(:with_instructions) { |_| self }
    mock_chat.define_singleton_method(:ask) { |_| mock_result }

    RubyLLM.stub(:chat, mock_chat) do
      result = PiyoChatService.respond(user: user, section: section, message: 'テスト質問')
      assert_equal 'テスト回答です', result
    end
  end

  test 'respond returns fallback on error' do
    section = textbook_sections(:section_variables)
    user = users(:hatsuno)

    RubyLLM.stub(:chat, ->(*) { raise StandardError, 'API error' }) do
      result = PiyoChatService.respond(user: user, section: section, message: 'テスト')
      assert_includes result, 'エラーが発生しました'
    end
  end
end
