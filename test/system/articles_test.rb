# frozen_string_literal: true

require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  setup do
    @article = articles(:article1)
  end

  # 仮デザインなので一時的に無効化
  # test 'show listing articles' do
  #   login_user 'komagata', 'testtest'
  #   visit_with_auth articles_url
  #   assert_text 'ブログ記事一覧'
  # end

  test 'create article' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: @article.title
    fill_in 'article[body]', with: @article.body
    click_on '登録する'

    assert_text '記事を作成しました'
  end

  test 'title & body not allow blank' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: ''
    fill_in 'article[body]', with: ''
    click_on '登録する'

    assert_text 'タイトルを入力してください'
    assert_text '本文を入力してください'
  end

  test "can't create article" do
    visit_with_auth articles_url, 'kimura'

    assert_no_text 'ブログ記事作成'

    visit new_article_path
    assert_text '管理者としてログインしてください'
  end

  test 'update article' do
    visit_with_auth articles_url, 'komagata'
    click_on '内容修正', match: :first

    fill_in 'article[title]', with: @article.title
    fill_in 'article[body]', with: @article.body
    click_on '更新する'

    assert_text '記事を更新しました'
  end

  test "can't update article" do
    visit_with_auth articles_url, 'kimura'

    assert_no_text '内容修正'

    visit edit_article_path(@article)
    assert_text '管理者としてログインしてください'
  end

  test 'delete article' do
    visit_with_auth articles_url, 'komagata'
    page.accept_confirm do
      click_on '削除', match: :first
    end

    assert_text '記事を削除しました'
  end

  test "can't delete article" do
    visit_with_auth articles_url, 'kimura'
    assert_no_text '削除'
  end
end
