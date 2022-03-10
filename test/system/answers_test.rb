# frozen_string_literal: true

require 'application_system_test_case'

class AnswersTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test 'answer form in questions/:id has comment tab and preview tab' do
    visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
    within('.a-form-tabs') do
      assert_text 'コメント'
      assert_text 'プレビュー'
    end
  end

  test 'post new comment for question' do
    visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('answer[description]', with: 'test')
    end
    page.all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
  end

  test 'edit answer form has comment tab and preview tab' do
    visit_with_auth "/questions/#{questions(:question3).id}", 'komagata'
    within('.thread-comment:first-child') do
      click_button '内容修正'
      assert_text 'コメント'
      assert_text 'プレビュー'
    end
  end

  test 'admin can edit and delete any questions' do
    visit_with_auth "/questions/#{questions(:question1).id}", 'komagata'
    assert_text 'vimしかないでしょう。常識的に考えて。'
    answer_by_user = page.all('.thread-comment')[1]
    within answer_by_user do
      assert_text '内容修正'
      assert_text '削除'
    end
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

    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      perform_enqueued_jobs do
        assert_no_text '解決済'
        accept_alert do
          click_button 'ベストアンサーにする'
        end
        assert_text '解決済'
      end
    end

    # Watcherに通知される
    visit_with_auth '/notifications?status=unread', 'kimura'
    assert_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'

    # Watchしていない回答者には通知されない
    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'

    # 質問者には通知されない
    visit_with_auth '/notifications?status=unread', 'sotugyou'
    assert_no_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'
  end
end
