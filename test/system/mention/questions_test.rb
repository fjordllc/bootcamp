# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mention_helper'

module Mention
  class QuestionsTest < ApplicationSystemTestCase
    include MentionHelper

    test 'mention from a question' do
      post_mention = lambda { |description|
        visit new_question_path
        fill_in 'question_title', with: 'メンション通知が送信されるかのテスト'
        fill_in 'question_description', with: description
        click_button '登録する'
      }

      assert_notify_mention(post_mention)
    end
  end
end
