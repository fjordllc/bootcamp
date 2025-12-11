# frozen_string_literal: true

require 'application_system_test_case'

class Articles::WipTest < ApplicationSystemTestCase
  setup do
    @article3 = articles(:article3)
  end

  test 'save article with WIP' do
    visit_with_auth new_article_path, 'komagata'

    fill_in 'article[title]', with: 'タイトル４'
    fill_in 'article[body]', with: '本文４'
    click_on 'WIP'
    assert_text '記事をWIPとして保存しました'
  end

  test 'WIP label visible on index and show' do
    visit_with_auth articles_wips_path, 'komagata'
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
    page.accept_confirm do
      click_on '公開する'
    end
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

  test 'mentor can see WIP label on index and show' do
    visit_with_auth articles_wips_path, 'mentormentaro'
    assert_text 'WIP'
    assert_text '執筆中'

    click_on @article3.title
    assert_text 'WIP'
    assert_text '執筆中'
    assert_selector 'head', visible: false do
      assert_selector "meta[name='robots'][content='none']", visible: false
    end
  end

  test 'WIP articles are not included in recent articles' do
    article = articles(:article1)
    wip_article1 = Article.create(
      title: '未公開の記事',
      body: '一度も公開したことがないWIP記事',
      user: users(:komagata),
      wip: true
    )
    wip_article2 = Article.create(
      title: '非公開の記事',
      body: '一度公開した後にWIPに戻した記事',
      user: users(:komagata),
      wip: true,
      published_at: '2022-01-03 00:00:00'
    )

    visit article_path articles(:article2)

    within '.card-list' do
      assert_no_text wip_article1.title
      assert_no_text wip_article2.title
      assert_text article.title
    end
  end

  test 'WIP article is not shown in atom feed' do
    visit_with_auth new_article_path, 'komagata'

    fill_in 'article[title]', with: 'WIPの記事は atom feed に表示されない'
    fill_in 'article[body]', with: 'WIPの記事は atom feed に表示されない'
    click_on 'WIP'
    assert_text '記事をWIPとして保存しました'

    visit '/articles.atom'
    assert_no_text 'WIPの記事は atom feed に表示されない'
  end

  test 'WIP articles are listed first in desc order' do
    # テストがわかりやすいように test/fixtures/article.yml の article3(WIP記事) からの連番で作成
    wip_article4 = Article.create(
      title: 'タイトル4',
      body: 'テスト用のWIP記事4',
      user: users(:komagata),
      wip: true
    )
    wip_article5 = Article.create(
      title: 'タイトル5',
      body: 'テスト用のWIP記事5',
      user: users(:komagata),
      wip: true,
      published_at: '2022-01-03 00:00:00'
    )

    visit_with_auth articles_wips_path, 'komagata'
    titles = all('h2.thumbnail-card__title').map(&:text)

    assert_equal ["WIP#{wip_article5.title}", "WIP#{wip_article4.title}", "WIP#{@article3.title}"], titles
  end

  test 'not logged-in users cannot view WIP articles without correct token' do
    visit article_path(@article3)
    assert_text '管理者・メンターとしてログインしてください'

    visit article_path(@article3, token: 'failed_token')
    assert_text 'token が一致しませんでした'

    visit article_path(@article3, token: @article3.token)
    assert_text @article3.title
    assert_selector 'head', visible: false do
      assert_selector "meta[name='robots'][content='noindex, nofollow']", visible: false
    end
  end
end
