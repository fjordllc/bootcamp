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
end
