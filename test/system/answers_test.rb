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

  test 'admin can edit and delete any questions' do
    visit_with_auth "/questions/#{questions(:question1).id}", 'komagata'
    assert_text 'vimしかないでしょう。常識的に考えて。'
    answer_by_user = page.all('.thread-comment')[1]
    within answer_by_user do
      assert_text '内容修正'
      assert_text '削除'
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
    assert_includes ['companies-logos-2.webp', 'default.png'], File.basename(find('img.thread-comment__company-logo')['src'])
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
