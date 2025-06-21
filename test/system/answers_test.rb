# frozen_string_literal: true

require 'application_system_test_case'

class AnswersTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

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
    assert_text 'Watch中'
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

  test 'clear preview after posting comment for question' do
    visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
    find('#js-new-comment').set('test')
    click_button 'コメントする'
    find('.thread-comment__description > div > p', text: 'test')
    find('.a-form-tabs__tab.js-tabs__tab', text: 'プレビュー').click
    within('#new-comment-preview') do
      assert_no_text :all, 'test'
    end
  end

  test 'the company logo is shown when an adviser who belongs to a company posts an answer' do
    visit_with_auth "/questions/#{questions(:question2).id}", 'senpai'
    within('.thread-comment-form__form') do
      fill_in('answer[description]', with: 'test')
    end
    page.all('.a-form-tabs__tab.js-tabs__tab')[1].click
    click_button 'コメントする'
    assert_text 'test'
    assert_includes ['2.webp', 'default.png'], File.basename(find('img.thread-comment__company-logo')['src'])
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth "/questions/#{questions(:question2).id}", 'senpai'
    within(:css, '.a-file-insert') do
      assert_selector 'input.new-comment-file-input', visible: false
    end
    assert_equal '.new-comment-file-input', find('textarea.a-text-input')['data-input']
  end

  test 'using file uploading by file selection dialogue in answers textarea' do
    visit_with_auth "/questions/#{questions(:question1).id}", 'komagata'
    assert_text 'atom一択です！'
    answer_by_user = page.all('.thread-comment')[0]
    within answer_by_user do
      click_button '内容修正'
    end
    test_target_label = page.all('.a-file-insert')[0]
    within test_target_label do
      assert_selector "input.js-comment-file-input-#{answers(:answer1).id}", visible: false
    end

    test_target_textarea = page.all('.form-textarea__body')[0]
    within test_target_textarea do
      assert_equal ".js-comment-file-input-#{answers(:answer1).id}", find('textarea.a-text-input')['data-input']
    end
  end
end
