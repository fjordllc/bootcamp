# frozen_string_literal: true

require 'application_system_test_case'

module Answers
  class FormTest < ApplicationSystemTestCase
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
end
