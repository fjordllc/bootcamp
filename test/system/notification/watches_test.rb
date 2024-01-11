# frozen_string_literal: true

require 'application_system_test_case'

class Notification::WatchesTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test '日報作成者がコメントをした際、ウォッチ通知が飛ばないバグの再現' do
    watches(:report1_watch_kimura)
    # コメントを投稿しても自動的にウォッチがONになる
    visit_with_auth "/reports/#{reports(:report1).id}", 'machida'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'いい日報ですね。')
    end
    click_button 'コメントする'
    logout

    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'コメントありがとうございます。')
    end
    click_button 'コメントする'
    assert_text 'コメントを投稿しました！'

    visit_with_auth '/notifications', 'kimura'

    within first('.card-list-item.is-unread') do
      assert_text "komagataさんの日報「#{reports(:report1).title}」にkomagataさんがコメントしました。"
    end

    visit_with_auth '/notifications', 'machida'

    within first('.card-list-item.is-unread') do
      assert_text "komagataさんの日報「#{reports(:report1).title}」にkomagataさんがコメントしました。"
    end
  end

  test '質問作成者がコメントをした際、ウォッチ通知が飛ばないバグの再現' do
    watches(:question1_watch_kimura)
    # 質問に回答しても自動でウォッチがつく
    visit_with_auth "/questions/#{questions(:question1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('answer[description]', with: 'Vimチュートリアルがおすすめです。')
    end
    click_button 'コメントする'
    logout

    visit_with_auth "/questions/#{questions(:question1).id}", 'machida'
    within('.thread-comment-form__form') do
      fill_in('answer[description]', with: '質問へのご回答ありがとうございます。')
    end
    click_button 'コメントする'
    assert_text '回答を投稿しました！'

    visit_with_auth '/notifications', 'kimura'

    within first('.card-list-item.is-unread') do
      assert_text "machidaさんのQ&A「#{questions(:question1).title}」にmachidaさんが回答しました。"
    end

    visit_with_auth '/notifications', 'komagata'

    within first('.card-list-item.is-unread') do
      assert_text "machidaさんのQ&A「#{questions(:question1).title}」にmachidaさんが回答しました。"
    end
  end
end
