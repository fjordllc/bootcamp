# frozen_string_literal: true

require 'browserless_system_test_case'

class Articles::WipBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @article3 = articles(:article3)
  end

  test 'WIP articles not visible to users' do
    visit_with_auth articles_url, 'kimura'
    assert_no_text 'WIP'
  end

  test 'WIP articles not accessible to users' do
    visit_with_auth article_path(@article3), 'kimura'
    assert_text '管理者・メンターとしてログインしてください'
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
