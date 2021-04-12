# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mention_helper'

module Mention
  class AnswersTest < ApplicationSystemTestCase
    include MentionHelper

    test 'mention from a answer' do
      post_mention = lambda { |answer|
        visit question_path(questions(:question8).id)
        within('.thread-comment-form__form') do
          fill_in('answer[description]', with: answer)
        end
        click_button 'コメントする'
      }
      assert_notify_mention(post_mention)
    end
  end
end
