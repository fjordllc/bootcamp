# frozen_string_literal: true

require 'application_system_test_case'

module Articles
  class PermissionTest < ApplicationSystemTestCase
    # 役割ごとの権限は test/integration/article_permissions_test.rb で確かめる。
    setup do
      @article = articles(:article1)
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

    test 'admin can delete an article' do
      visit_with_auth articles_path, 'komagata'
      assert_text @article.title

      visit article_path(@article)
      accept_confirm do
        click_on '削除'
      end

      assert_no_text @article.title
    end
  end
end
