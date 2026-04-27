# frozen_string_literal: true

require 'test_helper'

module Questions
  class QuestionPartialTest < ActionView::TestCase
    test 'renders WIP badge for WIP question' do
      render partial: 'questions/question', locals: { question: questions(:question_for_wip) }

      assert_select '.card-list-item.is-wip'
      assert_select '.a-list-item-badge.is-wip', text: 'WIP'
    end

    test 'renders answer count' do
      render partial: 'questions/question', locals: { question: questions(:question_for_comment_count) }

      assert_select '.a-meta', text: '回答・コメント（1）'
    end

    test 'marks answer count as important when answer does not exist' do
      question = questions(:question_for_wip)

      render partial: 'questions/question', locals: { question: }

      assert_select '.a-meta.is-important', text: '回答・コメント（0）'
    end
  end
end
