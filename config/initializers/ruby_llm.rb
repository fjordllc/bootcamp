# frozen_string_literal: true

RubyLLM.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
end
