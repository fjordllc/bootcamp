# frozen_string_literal: true

require 'application_system_test_case'

class Practice::NotLoggedInTest < ApplicationSystemTestCase
  test 'set ogp image to meta-tag when exists ogp image' do
    practice = practices(:practice1)
    visit_with_auth edit_mentor_practice_path(practice), 'komagata'
    within 'form[name=practice]' do
      attach_file 'practice[ogp_image]', 'test/fixtures/files/practices/ogp_images/1.jpg', make_visible: true
    end
    click_button '更新する'
    logout

    visit practice_path(practice)
    ogp_image = File.basename(find('meta[property="og:image"]', visible: false)['content'])
    twitter_card_image = File.basename(find('meta[name="twitter:image"]', visible: false)['content'])
    assert_equal '1.jpg', ogp_image
    assert_equal '1.jpg', twitter_card_image
  end

  test 'set default ogp image to meta-tag when do not exists ogp image' do
    practice = practices(:practice1)

    visit practice_path(practice)
    ogp_image = File.basename(find('meta[property="og:image"]', visible: false)['content'])
    twitter_card_image = File.basename(find('meta[name="twitter:image"]', visible: false)['content'])
    assert_equal 'ogp.png', ogp_image
    assert_equal 'ogp.png', twitter_card_image
  end
end
