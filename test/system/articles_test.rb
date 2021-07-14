# frozen_string_literal: true

require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  setup do
    @article = articles(:article1)
    @article3 = articles(:article3)
  end

  test 'show listing articles' do
    login_user 'komagata', 'testtest'
    visit articles_url
    assert_selector '.articles'
  end

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

  test "can't update article" do
    visit_with_auth articles_url, 'kimura'

    visit edit_article_path(@article)
    assert_text '管理者としてログインしてください'
  end

<<<<<<< HEAD
  test 'save article with WIP' do
    visit_with_auth new_article_path, 'komagata'

    fill_in 'article[title]', with: 'タイトル４'
    fill_in 'article[body]', with: '本文４'
    click_on 'WIP'
    assert_text 'WIPとして保存しました'
  end

  test 'WIP label visible on index and show' do
    visit_with_auth articles_path, 'komagata'
    assert_text 'WIP'
    assert_text '執筆中'

    click_on @article3.title
    assert_text 'WIP'
    assert_text '執筆中'
    assert_selector 'head', visible: false do
      assert_selector "meta[name='robots'][content='none']", visible: false
    end
  end

  test 'WIP articles not visible to users' do
    visit_with_auth articles_url, 'kimura'
    assert_no_text 'WIP'
  end

  test 'WIP articles not accessible to users' do
    visit_with_auth article_path(@article3), 'kimura'
    assert_text '管理者・メンターとしてログインしてください'
  end

  test 'no WIP marks after publication' do
    visit_with_auth edit_article_path(@article3), 'komagata'
    click_on '更新する'
    assert_no_text 'WIP'
    assert_no_text '執筆中'
    assert_selector 'head', visible: false do
      assert_no_selector "meta[name='robots'][content='none']", visible: false
    end

    visit_with_auth articles_url, 'kimura'
    assert_text @article3.title
    assert_no_text 'WIP'
    assert_no_text '執筆中'

    click_on @article3.title
    assert_text @article3.title
    assert_text @article3.body
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
