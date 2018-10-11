# frozen_string_literal: true

module UserDecorator
  def twitter_url
    "https://twitter.com/#{twitter_account}"
  end
end
