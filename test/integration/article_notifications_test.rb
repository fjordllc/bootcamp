# frozen_string_literal: true

require 'test_helper'

class ArticleNotificationsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    post user_sessions_path, params: { user: { login: 'komagata', password: 'testtest' } }
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'article for all notifies everyone except the sender and retired users' do
    article = create_article(title: '全員（退会者を除く）に通知する記事', target: 'all')

    assert_equal User.where(retired_on: nil).count - 1, notifications(article).count
    assert_equal 'komagataさんがブログに「全員（退会者を除く）に通知する記事」を投稿しました。', notifications(article).first.message
    assert_notified article, to: %i[sotugyou hajime], not_to: %i[komagata yameo]
  end

  test 'article for students notifies the active users, admins and mentors' do
    article = create_article(title: '現役生のみ通知する記事', target: 'students')

    assert_notified article, to: %i[kimura machida mentormentaro], not_to: %i[sotugyou advijirou yameo kensyu]
  end

  test 'article for job seekers notifies the job seekers, admins and mentors' do
    article = create_article(title: '就職希望者のみ通知する記事', target: 'job_seekers')

    assert_notified article, to: %i[jobseeker machida mentormentaro], not_to: %i[kimura]
  end

  test 'article for none notifies nobody' do
    article = create_article(title: '通知をしない記事', target: 'none')

    assert_empty notifications(article)
  end

  test 'notifies only when the article is first published' do
    article = create_article(title: 'WIPの記事', target: 'all', commit: 'WIP')
    assert article.wip?
    assert_empty notifications(article)

    perform_enqueued_jobs do
      patch article_path(article), params: { article: { title: '公開した記事' }, commit: '公開する' }
    end
    count = notifications(article).count
    assert_operator count, :>, 0

    perform_enqueued_jobs do
      patch article_path(article), params: { article: { title: '更新した記事' }, commit: '更新する' }
    end
    assert_equal count, notifications(article).count
  end

  test 'notification targets cannot be selected after the article is published' do
    get new_article_path
    assert_select 'input[name="article[target]"]'

    get edit_article_path(articles(:article1))
    assert_select 'input[name="article[target]"]', false
  end

  private

  def create_article(title:, target:, commit: '公開する')
    perform_enqueued_jobs do
      post articles_path, params: { article: { title:, body: 'test', target: }, commit: }
    end
    Article.find_by!(title:)
  end

  def notifications(article)
    Notification.where(kind: :create_article, link: "/articles/#{article.id}")
  end

  def assert_notified(article, to:, not_to:)
    receivers = notifications(article).map(&:user)
    to.each { |name| assert_includes receivers, users(name) }
    not_to.each { |name| assert_not_includes receivers, users(name) }
  end
end
