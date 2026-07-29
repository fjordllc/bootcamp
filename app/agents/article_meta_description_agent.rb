# frozen_string_literal: true

class ArticleMetaDescriptionAgent < RubyLLM::Agent
  model 'claude-sonnet-5'

  instructions { AiPrompt.body_for('article_meta_description') }
end
