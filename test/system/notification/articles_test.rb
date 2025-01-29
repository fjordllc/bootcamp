# frozen_string_literal: true

require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  setup do
    @article = articles(:article1)
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  # test 'the notification is sent only when the article is first published' do
  #   visit_with_auth new_article_path, 'komagata'
  #   fill_in('article_title', with: '通知テスト1回目')
  #   fill_in('article_body', with: 'test')
  #   click_on '公開する'
  #   assert_text '記事を作成しました'

  #   visit_with_auth notifications_path, 'hajime'
  #   within first('.card-list-item.is-unread') do
  #     assert_text 'komagataさんがブログに「通知テスト1回目」を投稿しました。'
  #   end
  #   click_link '全て既読にする'

  #   visit_with_auth edit_article_path(@article), 'komagata'
  #   fill_in('article_title', with: '通知テスト2回目')
  #   click_on '更新する'

  #   visit_with_auth notifications_path, 'hajime'
  #   assert_no_selector '.card-list-item.is-unread'
  #   assert_no_text 'komagataさんがブログに「通知テスト2回目」を投稿しました。'
  # end
  # 上のコードのコメントアウトは、以下のissueのための一時的なものなので、mergeされ次第コメントアウトを外すこと。
  # https://github.com/fjordllc/bootcamp/issues/8244

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
end
