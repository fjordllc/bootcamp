# frozen_string_literal: true

RubyLLM.configure do |config|
  config.openai_api_key = ENV['OPEN_AI_ACCESS_TOKEN']
  config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
end
