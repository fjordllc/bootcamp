# frozen_string_literal: true

require 'application_system_test_case'

class Practice::NotLoggedInTest < ApplicationSystemTestCase
  test 'set ogp image to meta-tag when exists ogp image' do
    practice = practices(:practice60)
    upload_ogp_image = practice.ogp_image.blob.filename.sanitized

    visit practice_path(practice)
    ogp_image = File.basename find('meta[property="og:image"]', visible: false)['content']
    twitter_card_image = File.basename find('meta[name="twitter:image"]', visible: false)['content']
    assert_equal upload_ogp_image, ogp_image
    assert_equal upload_ogp_image, twitter_card_image
  end

  test 'set default ogp image to meta-tag when do not exists ogp image' do
    practice = practices(:practice58)
    default_ogp_image = 'ogp.png'

    visit practice_path(practice)
    ogp_image = File.basename find('meta[property="og:image"]', visible: false)['content']
    twitter_card_image = File.basename find('meta[name="twitter:image"]', visible: false)['content']
    assert_equal default_ogp_image, ogp_image
    assert_equal default_ogp_image, twitter_card_image
  end
end
