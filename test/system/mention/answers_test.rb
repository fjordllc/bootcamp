# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mention_helper'

module Mention
  class AnswersTest < ApplicationSystemTestCase
    include MentionHelper
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

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
