# frozen_string_literal: true

require 'application_system_test_case'

class Notification::AnswersTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_text = 'komagataさんから回答がありました。'
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test "admin can resolve user's question" do
    visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
    assert_text 'ベストアンサーにする'
    accept_alert do
      click_button 'ベストアンサーにする'
    end
    assert_no_text 'ベストアンサーにする'
  end

  test 'delete best answer' do
    visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
    accept_alert do
      click_button 'ベストアンサーにする'
    end
    accept_alert do
      click_button 'ベストアンサーを取り消す'
    end
    assert_text 'ベストアンサーにする'
  end

  test 'notify watchers of best answer' do
    visit_with_auth "/questions/#{questions(:question2).id}", 'sotugyou'
    accept_confirm do
      click_button 'ベストアンサーにする'
    end

    # Watcherに通知される
    visit_with_auth '/notifications?status=unread', 'kimura'
    within first('.card-list-item.is-unread') do
      assert_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'
    end

    # Watchしていない回答者には通知されない
    visit_with_auth '/notifications?status=unread', 'komagata'
    within first('.card-list-item.is-unread') do
      assert_no_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'
    end

    # 質問者には通知されない
    visit_with_auth '/notifications?status=unread', 'sotugyou'
    within first('.card-list-item.is-unread') do
      assert_no_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'
    end
  end
end
