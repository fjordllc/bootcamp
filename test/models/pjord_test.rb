# frozen_string_literal: true

require 'test_helper'

class PjordTest < ActiveSupport::TestCase
  test '.user returns pjord user' do
    assert_equal 'pjord', Pjord.user.login_name
  end

  test '.respond returns a response' do
    mock_content = Minitest::Mock.new
    mock_content.expect(:content, 'テストの回答です。')

    mock_chat = Minitest::Mock.new
    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_tool, mock_chat, [BootcampSearchTool])
    mock_chat.expect(:with_tool, mock_chat, [UserInfoTool])
    mock_chat.expect(:with_schema, mock_chat, [PjordResponse])
    mock_chat.expect(:ask, mock_content, [String])

    RubyLLM.stub(:chat, mock_chat) do
      response = Pjord.respond(message: 'Rubyの配列について教えて')
      assert_equal 'テストの回答です。', response
    end
  end

  test '.respond returns nil on blank response' do
    mock_content = Minitest::Mock.new
    mock_content.expect(:content, '')

    mock_chat = Minitest::Mock.new
    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_tool, mock_chat, [BootcampSearchTool])
    mock_chat.expect(:with_tool, mock_chat, [UserInfoTool])
    mock_chat.expect(:with_schema, mock_chat, [PjordResponse])
    mock_chat.expect(:ask, mock_content, [String])

    RubyLLM.stub(:chat, mock_chat) do
      response = Pjord.respond(message: 'test')
      assert_nil response
    end
  end

  test '.respond removes internal preamble from response' do
    mock_content = Minitest::Mock.new
    mock_content.expect(:content, "\n検索結果を踏まえて、日報へのコメントを作成します。\n\n少しずつ進められていますね。")

    mock_chat = Minitest::Mock.new
    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_tool, mock_chat, [BootcampSearchTool])
    mock_chat.expect(:with_tool, mock_chat, [UserInfoTool])
    mock_chat.expect(:with_schema, mock_chat, [PjordResponse])
    mock_chat.expect(:ask, mock_content, [String])

    RubyLLM.stub(:chat, mock_chat) do
      response = Pjord.respond(message: 'test')
      assert_equal '少しずつ進められていますね。', response
    end
  end

  test '.respond extracts body from structured response' do
    mock_content = Minitest::Mock.new
    mock_content.expect(:content, '{"body":"公開する本文です。"}')

    mock_chat = Minitest::Mock.new
    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_tool, mock_chat, [BootcampSearchTool])
    mock_chat.expect(:with_tool, mock_chat, [UserInfoTool])
    mock_chat.expect(:with_schema, mock_chat, [PjordResponse])
    mock_chat.expect(:ask, mock_content, [String])

    RubyLLM.stub(:chat, mock_chat) do
      response = Pjord.respond(message: 'test')
      assert_equal '公開する本文です。', response
    end
  end

  test '.respond returns original response when JSON is not an object' do
    mock_content = Minitest::Mock.new
    mock_content.expect(:content, '["公開する本文です。"]')

    mock_chat = Minitest::Mock.new
    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_tool, mock_chat, [BootcampSearchTool])
    mock_chat.expect(:with_tool, mock_chat, [UserInfoTool])
    mock_chat.expect(:with_schema, mock_chat, [PjordResponse])
    mock_chat.expect(:ask, mock_content, [String])

    RubyLLM.stub(:chat, mock_chat) do
      response = Pjord.respond(message: 'test')
      assert_equal '["公開する本文です。"]', response
    end
  end

  test '.respond raises on API error for job retry' do
    RubyLLM.stub(:chat, ->(*) { raise StandardError, 'API error' }) do
      assert_raises(StandardError) do
        Pjord.respond(message: 'test')
      end
    end
  end

  test '.classify_report returns parsed intent hash' do
    mock_content = Minitest::Mock.new
    mock_content.expect(:content, '{"intent":"question","reason":"質問がある"}')

    mock_chat = Minitest::Mock.new
    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_schema, mock_chat, [PjordReportIntent])
    mock_chat.expect(:ask, mock_content, [String])

    RubyLLM.stub(:chat, mock_chat) do
      result = Pjord.classify_report(title: 'title', description: 'どうしてもエラーが解決できません')
      assert_equal 'question', result[:intent]
      assert_equal '質問がある', result[:reason]
    end
  end

  test '.classify_report returns nil on invalid intent' do
    mock_content = Minitest::Mock.new
    mock_content.expect(:content, '{"intent":"unknown","reason":"?"}')

    mock_chat = Minitest::Mock.new
    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_schema, mock_chat, [PjordReportIntent])
    mock_chat.expect(:ask, mock_content, [String])

    RubyLLM.stub(:chat, mock_chat) do
      assert_nil Pjord.classify_report(title: 't', description: 'd')
    end
  end

  test '.classify_report returns nil on JSON parse error' do
    mock_content = Minitest::Mock.new
    mock_content.expect(:content, 'not json')

    mock_chat = Minitest::Mock.new
    mock_chat.expect(:with_instructions, mock_chat, [String])
    mock_chat.expect(:with_schema, mock_chat, [PjordReportIntent])
    mock_chat.expect(:ask, mock_content, [String])

    RubyLLM.stub(:chat, mock_chat) do
      assert_nil Pjord.classify_report(title: 't', description: 'd')
    end
  end
end
