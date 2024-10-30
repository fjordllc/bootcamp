# frozen_string_literal: true

require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  setup do
    @article = articles(:article1)
    @article2 = articles(:article2)
    @article3 = articles(:article3)
  end

  test 'show listing articles' do
    visit_with_auth articles_url, 'komagata'
    assert_text 'ブログ'
    assert_selector '.articles'
  end

  test 'create article' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: @article.title
    fill_in 'article[body]', with: @article.body
    click_on '公開する'

    assert_text '記事を作成しました'
  end

  test 'title & body not allow blank' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: ''
    fill_in 'article[body]', with: ''
    click_on '公開する'

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
    click_on '公開する'
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
    click_on '公開する'

    assert_text '記事を作成しました'
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

  test 'show pagination' do
    Article.delete_all
    user = users(:komagata)
    number_of_pages = Article.page(1).limit_value + 1
    number_of_pages.times do
      Article.create(title: 'test title', body: 'test body', user_id: user.id, wip: false, published_at: Time.current)
    end

    visit_with_auth articles_url, 'komagata'
    assert_selector 'nav.pagination', count: 2
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

  test 'can select a contributor and create the article' do
    visit_with_auth new_article_path, 'komagata'

    fill_in 'article[title]', with: @article.title
    fill_in 'article[body]', with: @article.body
    find('.choices__inner').click
    find('#choices--js-choices-single-select-item-choice-6', text: 'mentormentaro').click
    click_on '公開する'

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

  test 'Summary text is used for meta description' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: @article.title
    fill_in 'article[summary]', with: 'サマリー１'
    fill_in 'article[body]', with: @article.body
    click_on '公開する'

    assert_text '記事を作成しました'
    assert_selector "meta[name='description'][content='サマリー１']", visible: false
    assert_selector "meta[property='og:description'][content='サマリー１']", visible: false
    assert_selector "meta[name='twitter:description'][content='サマリー１']", visible: false
  end

  test 'If there is no summary text, the fixed text is used for meta description' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: @article.title
    fill_in 'article[body]', with: @article.body
    click_on '公開する'

    assert_text '記事を作成しました'
    meta_description = '月額29,800円、全機能が使えるお試し期間付き。FBCは現場の即戦力になるためのスキルとプログラミングの楽しさを伝える、現役ソフトウェアエンジニアが考える理想のプログラミングスクールの実現に励んでいます。'
    assert_selector "meta[name='description'][content='#{meta_description}']", visible: false
    assert_selector "meta[property='og:description'][content='#{meta_description}']", visible: false
    assert_selector "meta[name='twitter:description'][content='#{meta_description}']", visible: false

    visit articles_path
    assert_no_text meta_description
  end

  test 'if there is no featured image, the default image is set as the OGP image' do
    visit_with_auth "/articles/#{@article3.id}", 'komagata'
    verify_default_ogp_image_used
  end

  test 'can set it as an OGP image by uploading an eye-catching image' do
    visit_with_auth edit_article_path(@article), 'komagata'
    find('label[for=article_thumbnail_type_prepared_thumbnail]').click
    attach_file 'article[thumbnail]', 'test/fixtures/files/articles/ogp_images/test.jpg', make_visible: true
    click_button '更新する'

    visit "/articles/#{@article.id}"
    meta = find('meta[name="twitter:image"]', visible: false)
    content = meta.native['content']
    assert_match(/test\.jpg$/, content)
  end

  test 'can set up prepared images for eye-catching image, the default OGP image will be used' do
    visit_with_auth edit_article_path(@article), 'komagata'
    find('label[for=article_thumbnail_type_ruby_on_rails]').click
    check 'サムネイル画像を本文に表示', allow_label_click: true
    click_button '更新する'

    visit "/articles/#{@article.id}"
    meta = find('meta[name="twitter:image"]', visible: false)
    content = meta.native['content']
    assert_match(/ruby_on_rails\.png$/, content)
  end

  test 'uncheck checkbox whether to display thumbnail in body' do
    visit_with_auth edit_article_path(@article), 'komagata'
    find('label[for=article_thumbnail_type_ruby_on_rails]').click
    uncheck 'サムネイル画像を本文に表示', allow_label_click: true
    click_button '更新する'

    visit "/articles/#{@article.id}"
    assert_no_selector 'img[class=article__image]'
  end

  test 'WIP articles are not included in recent articles' do
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
      assert_text @article.title
    end
  end

  test 'display recent 10 articles on article page' do
    Article.delete_all
    11.times do |i|
      Article.create(
        title: "test title #{i}",
        body: 'test body',
        user: users(:komagata),
        wip: false,
        published_at: "2021-12-31 #{i}:00:00"
      )
    end

    visit article_path Article.last.id
    titles = all('.card-list-item-title').map(&:text)

    within '.card-list' do
      assert_equal 'test title 10', titles.first
      assert_equal 'test title 1', titles.last
      assert_no_text 'test title 0'
      assert_equal all('.card-list-item').count, 10
    end
  end

  test 'GET /articles/{article_id}' do
    visit "/articles/#{@article.id}"
    assert_equal 'タイトル１ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'published_at can be changed' do
    visit_with_auth edit_article_path(@article), 'komagata'
    find('label.a-button.is-sm.is-secondary', text: '記事公開日時を変更').click
    fill_in 'article[published_at]', with: Time.zone.parse('2021-12-24 23:59')
    click_on '更新する'
    assert_text '2021年12月24日(金) 23:59'
  end

  test 'share button X' do
    visit "/articles/#{@article.id}"

    assert_selector 'a.x-share-button[href^="https://twitter.com/intent/tweet?url=https://bootcamp.fjord.jp/articles/"]', text: 'Postする'
  end

  test 'share button Facebook' do
    visit "/articles/#{@article.id}"

    within find('.fb-share-button', match: :first) do
      within_frame do
        assert_selector "a[href*='u=https%3A%2F%2Fbootcamp.fjord.jp%2Farticles%2F#{@article.id}']"
      end
    end
  end

  test 'share button Hatena' do
    visit "/articles/#{@article.id}"

    within_frame(find('.hatena-bookmark-button-frame', match: :first)) do
      assert_selector "a[href='https://b.hatena.ne.jp/entry/s/bootcamp.fjord.jp/articles/#{@article.id}#bbutton']"
    end
  end

  test 'items of article shown in atom feed' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: 'エントリーのタイトル（text）'
    fill_in 'article[summary]', with: 'サマリー（HTML）'
    fill_in 'article[body]', with: '本文（HTML）'
    within '.select-users' do
      find('.choices__inner').click
      find('#choices--js-choices-single-select-item-choice-6', text: 'mentormentaro').click
    end
    click_on '公開する'

    visit '/articles.atom'
    assert_text 'エントリーのタイトル（text）'
    assert_text '&lt;p&gt;サマリー（HTML）&lt;/p&gt;'
    assert_text '&lt;p&gt;本文（HTML）&lt;/p&gt;'
    assert_text 'mentormentaro'
  end

  test 'WIP article is not shown in atom feed' do
    visit_with_auth new_article_url, 'komagata'

    fill_in 'article[title]', with: 'WIPの記事は atom feed に表示されない'
    fill_in 'article[body]', with: 'WIPの記事は atom feed に表示されない'
    click_on 'WIP'
    assert_text '記事をWIPとして保存しました'

    visit '/articles.atom'
    assert_no_text 'WIPの記事は atom feed に表示されない'
  end

  test 'articles are displayed from the most recent publication date' do
    article4 = Article.create(
      title: 'タイトル4',
      body: 'テスト用のWIP記事4',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 4.days,
      updated_at: Date.current - 4.days,
      published_at: Date.current - 3.days
    )
    article5 = Article.create(
      title: 'タイトル5',
      body: 'テスト用のWIP記事5',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 5.days,
      updated_at: Date.current - 5.days,
      published_at: Date.current - 2.days
    )
    article6 = Article.create(
      title: 'タイトル6',
      body: 'テスト用のWIP記事6',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 6.days,
      updated_at: Date.current - 6.days,
      published_at: Date.current - 1.day
    )

    visit articles_url
    titles = all('h2.thumbnail-card__title').map(&:text)
    assert_equal [article6.title, article5.title, article4.title, @article2.title, @article.title], titles
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
