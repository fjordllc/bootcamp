# frozen_string_literal: true

require 'application_system_test_case'

module Articles
  class CreationTest < ApplicationSystemTestCase
    setup do
      @article = articles(:article1)
    end

    test 'create article' do
      visit_with_auth new_article_path, 'komagata'

      fill_in 'article[title]', with: @article.title
      fill_in 'article[body]', with: @article.body
      page.accept_confirm do
        click_on '公開する'
      end

      assert_text '記事を作成しました'
    end

    test 'title & body not allow blank' do
      visit_with_auth new_article_path, 'komagata'

      fill_in 'article[title]', with: ''
      fill_in 'article[body]', with: ''
      page.accept_confirm do
        click_on '公開する'
      end

      assert_text 'タイトルを入力してください'
      assert_text '本文を入力してください'
    end

    test 'mentor can create article' do
      visit_with_auth new_article_path, 'mentormentaro'

      fill_in 'article[title]', with: @article.title
      fill_in 'article[body]', with: @article.body
      page.accept_confirm do
        click_on '公開する'
      end

      assert_text '記事を作成しました'
    end

    test 'can select a contributor and create the article' do
      visit_with_auth new_article_path, 'komagata'

      fill_in 'article[title]', with: @article.title
      fill_in 'article[body]', with: @article.body
      find('.choices__inner').click
      find('#choices--js-choices-single-select-item-choice-6', text: 'mentormentaro').click
      page.accept_confirm do
        click_on '公開する'
      end

      assert_text '記事を作成しました'
      assert_text 'mentormentaro'
    end

    test 'can select a contributor and edit the article' do
      visit_with_auth edit_article_path(@article), 'mentormentaro'
      assert_text 'komagata'

      find('.choices__inner').click
      find('#choices--js-choices-single-select-item-choice-6', text: 'mentormentaro').click
      click_on '更新する'

      assert_text '記事を更新しました'
      assert_text 'mentormentaro'
    end

    test 'published_at can be changed' do
      visit_with_auth edit_article_path(@article), 'komagata'
      find('label.a-button.is-sm.is-secondary', text: '記事公開日時を変更').click
      fill_in 'article[published_at]', with: Time.zone.parse('2021-12-24 23:59')
      click_on '更新する'
      assert_text '2021年12月24日(金) 23:59'
    end
  end
end
