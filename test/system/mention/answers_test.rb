# frozen_string_literal: true

require 'application_system_test_case'

module Mention
  class AnswersTest < ApplicationSystemTestCase
    setup do
      login_user 'komagata', 'testtest'
    end

    test "recieve a notification when I got my question's answer" do
      visit "/questions/#{questions(:question8).id}"
      within('.thread-comment-form__form') do
        fill_in('answer[description]', with: '@hatsuno test')
      end
      click_button 'コメントする'
      wait_for_vuejs
      logout
  
      login_user 'hatsuno', 'testtest'
      visit '/notifications'
      assert_text 'komagataさんからメンションがきました。'
    end
  end
end
