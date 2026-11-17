# frozen_string_literal: true

require 'browserless_system_test_case'

class Practice::NotLoggedInBrowserlessTest < BrowserlessSystemTestCase
  test 'set default ogp image to meta-tag when do not exists ogp image' do
    practice = practices(:practice1)

    visit practice_path(practice)
    ogp_image = File.basename(find('meta[property="og:image"]', visible: false)['content'])
    twitter_card_image = File.basename(find('meta[name="twitter:image"]', visible: false)['content'])
    assert_equal 'ogp.png', ogp_image
    assert_equal 'ogp.png', twitter_card_image
  end

  test 'appropriate meta description is displayed when accessed by non-logged-in user' do
    visit "/practices/#{practices(:practice1).id}"

    assert_selector 'head', visible: false do
      assert_selector "meta[name='description'][content='オンラインプログラミングスクール「フィヨルドブートキャンプ」のプラクティス「#{practices(:practice1).title}」のページです。']", visible: false
    end
  end
end
