# frozen_string_literal: true

require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  setup do
    @article = articles(:article1)
    @article3 = articles(:article3)
  end

  test 'show listing articles' do
    visit_with_auth articles_url, 'komagata'
    assert_text 'ブログ記事一覧'
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
    assert_text '管理者・メンターとしてログインしてください'
  end

  test "can't update article" do
    visit_with_auth articles_url, 'kimura'

    visit edit_article_path(@article)
    assert_text '管理者・メンターとしてログインしてください'
  end

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

  test 'mentor can create article' do
    visit_with_auth new_article_url, 'mentormentaro'

    fill_in 'article[title]', with: @article.title
    fill_in 'article[body]', with: @article.body
    click_on '登録する'

    assert_text '記事を作成しました'
  end

  test 'mentor can see WIP label on index and show' do
    visit_with_auth articles_path, 'mentormentaro'
    assert_text 'WIP'
    assert_text '執筆中'

    click_on @article3.title
    assert_text 'WIP'
    assert_text '執筆中'
    assert_selector 'head', visible: false do
      assert_selector "meta[name='robots'][content='none']", visible: false
    end
  end

  test 'show pagination' do
    Article.delete_all
    user = users(:komagata)
    number_of_pages = Article.page(1).limit_value + 1
    number_of_pages.times do
      Article.create(title: 'test title', body: 'test body', user_id: user.id, wip: false, published_at: Time.current)
    end

    visit_with_auth articles_url, 'komagata'
    find 'nav.pagination'
  end

  test "can't see edit and delete buttons" do
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
