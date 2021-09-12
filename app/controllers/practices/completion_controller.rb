# frozen_string_literal: true

class Practices::CompletionController < ApplicationController
  before_action :set_practice

  def show
    completion_text = "「#{@practice.title}」を修了しました！"
    @image = OgpCreator.build(completion_text)

    # ref: https://developer.twitter.com/en/docs/twitter-for-websites/tweet-button/guides/web-intent
    tweet_param = URI.encode_www_form(text: completion_text, url: request.url, hashtags: 'fjordbootcamp')
    @tweet_url = "https://twitter.com/intent/tweet?#{tweet_param}"
  end

  private

  def set_practice
    @practice = Practice.find(params[:practice_id])
  end
end
