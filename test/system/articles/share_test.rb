# frozen_string_literal: true

require 'application_system_test_case'

module Articles
  class ShareTest < ApplicationSystemTestCase
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

    test 'share button Hatena' do
      widget_url = 'https://b.st-hatena.com/js/bookmark_button.js'
      image_url = 'https://b.st-hatena.com/images/v4/public/entry-button/button-only@2x.png'
      block_widget = ->(route, _request) { route.abort }
      page.driver.with_playwright_page do |playwright_page|
        # Verify our embed markup without depending on Hatena's generated iframe or shadow DOM.
        playwright_page.route(widget_url, block_widget)
        playwright_page.route(image_url, block_widget)
        visit "/articles/#{@article.id}"

        assert_selector "a.hatena-bookmark-button[href='https://b.hatena.ne.jp/entry/s/bootcamp.fjord.jp/articles/#{@article.id}']" \
                        '[data-hatena-bookmark-layout="vertical-normal"][data-hatena-bookmark-lang="ja"]'
        assert_selector "script[src='#{widget_url}']", visible: :all
      ensure
        playwright_page.unroute(widget_url, handler: block_widget)
        playwright_page.unroute(image_url, handler: block_widget)
      end
    end

    test 'items of article shown in atom feed' do
      visit_with_auth new_article_path, 'komagata'

      fill_in 'article[title]', with: 'エントリーのタイトル（text）'
      fill_in 'article[summary]', with: 'サマリー（HTML）'
      fill_in 'article[body]', with: '本文（HTML）'
      within '.select-users' do
        find('.choices__inner').click
        find('#choices--js-choices-single-select-item-choice-6', text: 'mentormentaro').click
      end
      page.accept_confirm do
        click_on '公開する'
      end
      assert_text 'エントリーのタイトル（text）'
      assert_text '本文（HTML）'

      visit '/articles.atom'
      assert_text 'エントリーのタイトル（text）'
      assert_text '&lt;p&gt;サマリー（HTML）&lt;/p&gt;'
      assert_text '&lt;p&gt;本文（HTML）&lt;/p&gt;'
      assert_text 'mentormentaro'
    end
  end
end
