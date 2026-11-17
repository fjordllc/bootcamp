# frozen_string_literal: true

require 'browserless_system_test_case'

class Articles::ThumbnailBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @article = articles(:article1)
    @article3 = articles(:article3)
  end

  test 'if there is no featured image, the default image is set as the OGP image' do
    visit_with_auth "/articles/#{@article3.id}", 'komagata'
    verify_default_ogp_image_used
  end
end
