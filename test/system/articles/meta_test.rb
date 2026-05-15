# frozen_string_literal: true

require 'application_system_test_case'

module Articles
  class MetaTest < ApplicationSystemTestCase
    setup do
      @article = articles(:article1)
    end

    test 'Summary text is used for meta description' do
      visit_with_auth new_article_path, 'komagata'

      fill_in 'article[title]', with: @article.title
      fill_in 'article[summary]', with: 'サマリー１'
      fill_in 'article[body]', with: @article.body
      page.accept_confirm do
        click_on '公開する'
      end

      assert_text '記事を作成しました'
      assert_selector "meta[name='description'][content='サマリー１']", visible: false
      assert_selector "meta[property='og:description'][content='サマリー１']", visible: false
      assert_selector "meta[name='twitter:description'][content='サマリー１']", visible: false
    end

    test 'If there is no summary text, the fixed text is used for meta description' do
      visit_with_auth new_article_path, 'komagata'

      fill_in 'article[title]', with: @article.title
      fill_in 'article[body]', with: @article.body
      page.accept_confirm do
        click_on '公開する'
      end

      assert_text '記事を作成しました'
      meta_description = '月額32,780円（税込）、全機能が使えるお試し期間付き。FBCは現場の即戦力になるためのスキルとプログラミングの楽しさを伝える、現役ソフトウェアエンジニアが考える理想のプログラミングスクールの実現に励んでいます。'
      assert_selector "meta[name='description'][content='#{meta_description}']", visible: false
      assert_selector "meta[property='og:description'][content='#{meta_description}']", visible: false
      assert_selector "meta[name='twitter:description'][content='#{meta_description}']", visible: false

      visit articles_path
      assert_no_text meta_description
    end
  end
end
