# frozen_string_literal: true

require 'test_helper'

class ArticleMetaDescriptionAgentTest < ActiveSupport::TestCase
  test 'uses the saved prompt' do
    AiPrompt.create!(key: 'article_meta_description', body: '保存したmeta descriptionプロンプト')
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, chat) do
      ArticleMetaDescriptionAgent.new.ask('記事本文')
    end

    assert_equal '保存したmeta descriptionプロンプト', chat.instructions
  end

  test 'uses the default prompt when no prompt is saved' do
    chat = AgentChatFake.new

    RubyLLM.stub(:chat, chat) do
      ArticleMetaDescriptionAgent.new.ask('記事本文')
    end

    assert_equal AiPrompt.default_body_for('article_meta_description'), chat.instructions
  end

  class AgentChatFake
    attr_reader :instructions

    def with_instructions(instructions)
      @instructions = instructions
      self
    end

    def ask(*)
      Struct.new(:content).new('meta description')
    end
  end
end
