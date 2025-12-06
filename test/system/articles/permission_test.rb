# frozen_string_literal: true

require 'application_system_test_case'

module Articles
  class PermissionTest < ApplicationSystemTestCase
    setup do
      @article = articles(:article1)
    end

    test "can't create article" do
      visit_with_auth articles_url, 'kimura'

      assert_no_text 'ブログ記事作成'

      visit new_article_path
      assert_text '管理者・メンターとしてログインしてください'
    end

    test "can't update article" do
      visit_with_auth articles_url, 'kimura'

      visit edit_article_path(@article)
      assert_text '管理者・メンターとしてログインしてください'
    end

    test "general user can't see edit and delete buttons" do
      visit_with_auth article_path(@article), 'kimura'
      assert_no_text '内容修正'
      assert_no_text '削除'
    end

    test 'admin can see edit and delete buttons' do
      visit_with_auth article_path(@article), 'komagata'
      assert_text '内容修正'
      assert_text '削除'
    end

    test 'mentor can see edit and delete buttons' do
      visit_with_auth article_path(@article), 'mentormentaro'
      assert_text '内容修正'
      assert_text '削除'
    end

    test 'admin can edit an article' do
      visit_with_auth article_path(@article), 'komagata'
      assert_text @article.title
      click_on '内容修正'

      fill_in 'article[title]', with: 'edited by mentor'
      click_on '更新する'

      visit article_path(@article)
      assert_text 'edited by mentor'
    end

    test 'mentor can edit an article' do
      visit_with_auth article_path(@article), 'mentormentaro'
      assert_text @article.title
      click_on '内容修正'

      fill_in 'article[title]', with: 'edited by mentor'
      click_on '更新する'

      visit article_path(@article)
      assert_text 'edited by mentor'
    end

    test 'admin can delete an article' do
      visit_with_auth articles_path, 'komagata'
      assert_text @article.title

      visit article_path(@article)
      accept_confirm do
        click_on '削除'
      end

      assert_no_text @article.title
    end

    test 'mentor can delete an article' do
      visit_with_auth articles_path, 'mentormentaro'
      assert_text @article.title

      visit article_path(@article)
      accept_confirm do
        click_on '削除'
      end

      assert_no_text @article.title
    end
  end
end
