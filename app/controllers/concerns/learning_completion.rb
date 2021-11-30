# frozen_string_literal: true

module LearningCompletion
  extend ActiveSupport::Concern

  private

  def tweet_url(practice:)
    completion_text = "フィヨルドブートキャンプのプラクティス「#{practice.title}」を修了しました🎉🎉🎉"
    # ref: https://developer.twitter.com/en/docs/twitter-for-websites/tweet-button/guides/web-intent
    tweet_param = URI.encode_www_form(text: completion_text, url: practice_completion_url(practice_id: practice.id), hashtags: 'fjordbootcamp')
    "https://twitter.com/intent/tweet?#{tweet_param}"
  end
end
