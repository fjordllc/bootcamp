# frozen_string_literal: true

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test '.with_attachments_and_user' do
    articles = Article.with_attachments_and_user

    articles.each do |article|
      assert_not_nil article.user
      assert_not_nil article.user.avatar_attachment
      assert_not article.wip
    end
  end

  test '.press_release includes only not wip articles with press release tag' do
    article1 = Article.create(
      title: 'プレスリリースタグのみを持つブログ',
      body: 'test',
      user: users(:komagata),
      wip: false
    )
    article1.tag_list.add('プレスリリース')
    article1.save

    article2 = Article.create(
      title: '2つのタグを持つブログ',
      body: 'test',
      user: users(:komagata),
      wip: false
    )
    article2.tag_list.add('test', 'プレスリリース')
    article2.save

    wip_article = Article.create(
      title: 'プレスリリースタグを持つwipブログ',
      body: 'test',
      user: users(:komagata),
      wip: true
    )
    wip_article.tag_list.add('プレスリリース')
    wip_article.save

    press_releases = Article.press_releases
    assert_equal [article2, article1], press_releases
    press_releases.each do |press_release|
      assert_includes press_release.tag_list, 'プレスリリース'
      assert_not press_release.wip
    end
  end

  test '.press_release orders by published_at in descending order' do
    three_days_ago_press_release = Article.create(
      title: '3日前に公開されたプレスリリース',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 4.days,
      updated_at: Date.current - 4.days,
      published_at: Date.current - 3.days
    )
    three_days_ago_press_release.tag_list.add('プレスリリース')
    three_days_ago_press_release.save

    two_days_ago_press_release = Article.create(
      title: '2日前に公開されたプレスリリース',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 5.days,
      updated_at: Date.current - 5.days,
      published_at: Date.current - 2.days
    )
    two_days_ago_press_release.tag_list.add('プレスリリース')
    two_days_ago_press_release.save

    one_day_ago_press_release = Article.create(
      title: '1日前に公開されたプレスリリース',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 6.days,
      updated_at: Date.current - 6.days,
      published_at: Date.current - 1.day
    )
    one_day_ago_press_release.tag_list.add('プレスリリース')
    one_day_ago_press_release.save

    press_releases = Article.press_releases
    assert_equal [one_day_ago_press_release, two_days_ago_press_release, three_days_ago_press_release], press_releases
  end

  test '.press_release return all records when no limit is specified' do
    records_count = 10
    records_count.times do |i|
      press_release = Article.create(
        title: "press releases #{i}",
        body: 'プレスリリースのタグを持つブログ記事',
        user: users(:komagata),
        wip: false,
        published_at: "2022-1-1 00:00:#{i}"
      )
      press_release.tag_list.add('プレスリリース')
      press_release.save
    end

    press_releases = Article.press_releases
    assert_equal records_count, press_releases.length
  end

  test '.press_release return the specified number of records by limit' do
    10.times do |i|
      press_release = Article.create(
        title: "press releases #{i}",
        body: 'プレスリリースのタグを持つブログ記事',
        user: users(:komagata),
        wip: false,
        published_at: "2022-1-1 00:00:#{i}"
      )
      press_release.tag_list.add('プレスリリース')
      press_release.save
    end

    limit = 5
    press_releases = Article.press_releases(limit)
    assert_equal limit, press_releases.length
  end

  test '#prepared_thumbnail_url' do
    article = articles(:article3)
    assert_equal '/ogp/blank.svg', article.prepared_thumbnail_url
  end

  test '#selected_thumbnail_url' do
    article = articles(:article1)
    assert_equal '/ogp/ruby_on_rails.png', article.selected_thumbnail_url
  end

  test '#published?' do
    assert articles(:article1).published?
    assert_not articles(:article3).published?
  end

  test '#before_initial_publish?' do
    assert_not articles(:article1).before_initial_publish?
    assert articles(:article3).before_initial_publish?
  end

  test '#generate_token!' do
    test_article = Article.create(
      title: 'サンプル記事',
      body: 'サンプル記事本文',
      user: users(:komagata),
      wip: true
    )
    test_article.generate_token!
    assert_not_nil test_article.token

    maintained_tokens = test_article.token
    test_article.generate_token!
    assert_equal maintained_tokens, test_article.token
  end

  test 'articles directly published without WIP have value of the published_at' do
    article = Article.create(
      title: '公開された記事',
      body: 'WIPを経由せずに公開された記事本文',
      user: users(:komagata),
      wip: false
    )
    assert article.published_at?
  end

  test 'once articles published, value of the published_at can be kept at WIP.' do
    article = Article.create(
      title: '一度公開された記事をWIPに',
      body: '一度公開され、その後WIPになった記事本文',
      user: users(:komagata),
      wip: false
    )
    published_at_when_not_wip = article.published_at

    article.update(
      wip: true
    )
    assert_equal article.published_at, published_at_when_not_wip
  end

  test 'articles directly kept at WIP do not have value of the published_at' do
    article = Article.create(
      title: '未公開の記事',
      body: '一度も公開したことがないWIP記事',
      user: users(:komagata),
      wip: true
    )
    assert_nil article.published_at
  end

  test 'once articles directly kept at WIP is published, value of the published_at is not nil' do
    article = Article.create(
      title: '未公開の記事',
      body: '一度も公開したことがないWIP記事',
      user: users(:komagata),
      wip: true
    )

    article.update(
      wip: false
    )
    assert article.published_at?
  end

  test '.alumni_voices includes only not wip articles with alumni voice tag' do
    article1 = Article.create(
      title: '卒業生の声タグのみを持つブログ',
      body: 'test',
      user: users(:komagata),
      wip: false
    )
    article1.tag_list.add('卒業生の声')
    article1.save

    article2 = Article.create(
      title: '2つのタグを持つブログ',
      body: 'test',
      user: users(:komagata),
      wip: false
    )
    article2.tag_list.add('test', '卒業生の声')
    article2.save

    wip_article = Article.create(
      title: '卒業生の声タグを持つwipブログ',
      body: 'test',
      user: users(:komagata),
      wip: true
    )
    wip_article.tag_list.add('卒業生の声')
    wip_article.save

    alumni_voices = Article.alumni_voices
    assert_equal [article2, article1], alumni_voices
    alumni_voices.each do |alumni_voice|
      assert_includes alumni_voice.tag_list, '卒業生の声'
      assert_not alumni_voice.wip
    end
  end
  test '.alumni_voices orders by published_at in descending order' do
    three_days_ago_alumni_voice = Article.create(
      title: '3日前に公開された卒業生の声',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 4.days,
      updated_at: Date.current - 4.days,
      published_at: Date.current - 3.days
    )
    three_days_ago_alumni_voice.tag_list.add('卒業生の声')
    three_days_ago_alumni_voice.save

    two_days_ago_alumni_voice = Article.create(
      title: '2日前に公開された卒業生の声',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 5.days,
      updated_at: Date.current - 5.days,
      published_at: Date.current - 2.days
    )
    two_days_ago_alumni_voice.tag_list.add('卒業生の声')
    two_days_ago_alumni_voice.save

    one_day_ago_alumni_voice = Article.create(
      title: '1日前に公開された卒業生の声',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 6.days,
      updated_at: Date.current - 6.days,
      published_at: Date.current - 1.day
    )
    one_day_ago_alumni_voice.tag_list.add('卒業生の声')
    one_day_ago_alumni_voice.save

    alumni_voices = Article.alumni_voices
    assert_equal [one_day_ago_alumni_voice, two_days_ago_alumni_voice, three_days_ago_alumni_voice], alumni_voices
  test 'featured scope returns articles tagged with "注目の記事" in descending order and limited to 6' do
    7.times do |i|
      article = Article.create!(
        wip: false,
        published_at: Date.parse('2024-02-01') + i,
        created_at: Date.parse('2024-02-01') + i,
        title: '注目の記事#{i}',
        body: '注目の記事#{i}本文',
        user: users(:komagata)
      )
      article.tag_list.add('注目の記事')
      article.save!
    end

    2.times do |i|
      Article.create!(
        wip: false,
        published_at: Date.parse('2024-02-01') + i,
        created_at: Date.parse('2024-02-01') + i,
        title: '通常の記事#{i}',
        body: '通常の記事#{i}本文',
        user: users(:komagata)
      )
    end

    articles = Article.featured
    assert_equal 6, articles.size

    articles.each do |article|
      assert_not article.wip?
      assert_includes article.tag_list, '注目の記事'
    end

    published_dates = articles.map(&:published_at)
    assert_equal published_dates.sort.reverse, published_dates
  test 'articles are sorted by published_at descending' do
    articles = [
      articles(:article27),
      articles(:article26),
      articles(:article25),
      articles(:article24),
      articles(:article23),
      articles(:article22),
      articles(:article21)
    ]
    assert_equal articles.sort_by(&:published_at).reverse, articles
  end
end
