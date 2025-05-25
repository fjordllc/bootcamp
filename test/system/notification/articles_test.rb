# frozen_string_literal: true

require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  setup do
    @article = articles(:article1)
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_kind = Notification.kinds[:create_article]
    @notified_count = Notification.where(kind: @notice_kind).size
    @receiver_count = User.where(retired_on: nil).size - 1 # 送信者は除くため-1
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'the notification is sent only when the article is first published' do
    visit_with_auth new_article_path, 'komagata'
    fill_in('article_title', with: '通知テスト1回目')
    fill_in('article_body', with: 'test')
    page.accept_confirm do
      click_on '公開する'
    end
    assert_text '記事を作成しました'

    visit_with_auth notifications_path, 'hajime'
    within first('.card-list-item.is-unread') do
      assert_text 'komagataさんがブログに「通知テスト1回目」を投稿しました。'
    end
    click_link '全て既読にする'

    visit_with_auth edit_article_path(@article), 'komagata'
    fill_in('article_title', with: '通知テスト2回目')
    click_on '更新する'

    visit_with_auth notifications_path, 'hajime'
    assert_no_selector '.card-list-item.is-unread'
    assert_no_text 'komagataさんがブログに「通知テスト2回目」を投稿しました。'
  end

  test 'the notification is not sent when the article with WIP is saved' do
    visit_with_auth new_article_path, 'komagata'
    fill_in('article_title', with: '通知テストwip')
    fill_in('article_body', with: 'test')
    click_on 'WIP'
    assert_text '記事をWIPとして保存しました'

    visit_with_auth notifications_path, 'hajime'
    assert_no_selector '.card-list-item.is-unread'
    assert_no_text 'komagataさんがブログに「通知テストwip」を投稿しました。'
  end

  test 'all member recieve a notification when the article posted' do
    visit_with_auth new_article_path, 'komagata'
    within 'form[id="article_form"]' do
      fill_in('article_title', with: '全員（退会者を除く）に通知する記事')
      fill_in('article_body', with: 'この記事は全員（退会者を除く）に届きます。')
      choose '全員（退会者を除く）', allow_label_click: true
      page.accept_confirm do
        click_on '公開する'
      end
    end
    assert_text '記事を作成しました'

    message = 'komagataさんがブログに「全員（退会者を除く）に通知する記事」を投稿しました。'
    visit_with_auth '/notifications', 'sotugyou'
    within first('.card-list-item.is-unread') do
      assert_text message
    end

    visit_with_auth '/', 'komagata'
    assert_no_text message

    expected = @notified_count + @receiver_count
    actual = Notification.where(kind: @notice_kind).size
    assert_equal expected, actual
  end

  test 'article to Only Active Users notifies the active users, admins, mentors' do
    visit_with_auth new_article_path, 'komagata'

    within 'form[id="article_form"]' do
      fill_in('article_title', with: '現役生のみ通知する記事')
      fill_in('article_body', with: 'この記事は現役生と管理者、メンターにのみ届きます。')
      choose '現役生のみ', allow_label_click: true
      page.accept_confirm do
        click_on '公開する'
      end
    end
    assert_text '記事を作成しました'

    message = 'komagataさんがブログに「現役生のみ通知する記事」を投稿しました。'
    notified_users = %w[kimura machida mentormentaro]
    notified_users.each do |user|
      visit_with_auth '/notifications', user
      assert_text message
    end

    not_notified_users = %w[sotugyou advijirou yameo kensyu]
    not_notified_users.each do |user|
      visit_with_auth '/notifications', user
      assert_no_text message
    end
  end

  test 'article to Only Job Seekers notifies the job seekers, admins, mentors' do
    visit_with_auth new_article_path, 'komagata'
    within 'form[id="article_form"]' do
      fill_in('article_title', with: '就職希望者のみ通知する記事')
      fill_in('article_body', with: 'この記事は就職希望者と管理者、メンターにのみ届きます。')
      choose '就職希望者のみ', allow_label_click: true
      page.accept_confirm do
        click_on '公開する'
      end
    end
    assert_text '記事を作成しました'

    message = 'komagataさんがブログに「就職希望者のみ通知する記事」を投稿しました。'
    notified_users = %w[jobseeker machida mentormentaro]
    notified_users.each do |user|
      visit_with_auth '/notifications', user
      assert_text message
    end

    not_notified_users = %w[kimura]
    not_notified_users.each do |user|
      visit_with_auth '/notifications', user
      assert_no_text message
    end
  end

  test 'the notification is not sent when target is none' do
    visit_with_auth new_article_path, 'komagata'
    within 'form[id="article_form"]' do
      fill_in('article_title', with: '通知をしない記事')
      fill_in('article_body', with: 'この記事は通知をしません。')
      choose '通知しない', allow_label_click: true
      page.accept_confirm do
        click_on '公開する'
      end
    end

    visit_with_auth notifications_path, 'hajime'
    assert_no_selector '.card-list-item.is-unread'
    assert_no_text 'komagataさんがブログに「通知をしない記事」を投稿しました。'
  end

  test 'notification targets can be selected only when first published' do
    visit_with_auth edit_article_path(@article), 'komagata'
    assert_no_selector 'input[name="article[target]"]'
  end
end
