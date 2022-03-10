# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mention_helper'

module Mention
  class CommentsTest < ApplicationSystemTestCase
    include MentionHelper

    test 'mention from a comment' do
      post_mention = lambda { |comment|
        visit report_path(reports(:report1).id)
        within('.thread-comment-form__form') do
          fill_in('new_comment[description]', with: comment)
        end
        click_button 'コメントする'
      }
      assert_notify_mention(post_mention)
    end
  end
end
