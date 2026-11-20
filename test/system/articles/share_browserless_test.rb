# frozen_string_literal: true

require 'browserless_system_test_case'

module Articles
  class ShareBrowserlessTest < BrowserlessSystemTestCase
    setup do
      @article = articles(:article1)
    end

    test 'share button X' do
      visit "/articles/#{@article.id}"

      assert_selector 'a.x-share-button[href^="https://twitter.com/intent/tweet?url=https://bootcamp.fjord.jp/articles/"]', text: 'Postする'
    end

    test 'share button Facebook' do
      visit "/articles/#{@article.id}"

      assert_selector '#fb-root', minimum: 1, visible: :all
      assert_selector ".fb-share-button[data-href='https://bootcamp.fjord.jp/articles/#{@article.id}']", visible: :all
    end
  end
end
