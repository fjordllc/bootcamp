# frozen_string_literal: true

module ArticleHelper
  def verify_default_ogp_image_used
    ogp_twitter = find('meta[name="twitter:image"]', visible: false)
    ogp_twitter_content = ogp_twitter.native['content']
    ogp_othter = find('meta[property="og:image"]', visible: false)
    ogp_othter_content = ogp_othter.native['content']
    assert_match(/ogp\.png$/, ogp_twitter_content)
    assert_match(/ogp\.png$/, ogp_othter_content)
  end
end
