# frozen_string_literal: true

require 'test_helper'

class ArticlePermissionsTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:article1)
  end

  test 'student cannot create or update article' do
    login('kimura')
    get articles_path
    assert_response :success
    assert_not_includes response.body, 'ブログ記事作成'

    [new_article_path, edit_article_path(@article)].each do |path|
      get path
      follow_redirect!
      assert_includes response.body, '管理者・メンターとしてログインしてください'
    end
  end

  %w[komagata mentormentaro].each do |login_name|
    test "#{login_name} can edit an article" do
      login(login_name)
      get article_path(@article)
      assert_select 'a[href=?]', edit_article_path(@article), text: '内容修正'

      patch article_path(@article), params: { article: { title: 'edited by mentor' } }
      get article_path(@article)
      assert_includes response.body, 'edited by mentor'
    end

    test "#{login_name} can delete an article" do
      login(login_name)
      get article_path(@article)
      assert_select 'a[href=?]', article_path(@article), text: '削除'

      assert_difference 'Article.count', -1 do
        delete article_path(@article)
      end
      follow_redirect!
      assert_not_includes response.body, @article.title
    end
  end

  private

  def login(login_name)
    post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
  end
end
