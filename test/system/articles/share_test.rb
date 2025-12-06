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

      within first('.fb-share-button') do
        within_frame do
          assert_selector "a[href*='u=https%3A%2F%2Fbootcamp.fjord.jp%2Farticles%2F#{@article.id}']"
        end
      end
    end

    test 'share button Hatena' do
      visit "/articles/#{@article.id}"

      within_frame(first('.hatena-bookmark-button-frame')) do
        assert_selector "a[href='https://b.hatena.ne.jp/entry/s/bootcamp.fjord.jp/articles/#{@article.id}#bbutton']"
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
