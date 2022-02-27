# frozen_string_literal: true

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  test '#will_be_published? ' do
    kimura = users(:kimura)

    question1 = kimura.questions.new(title: '質問タイトル', description: '質問本文', wip: false)
    assert question1.will_be_published?

    question2 = kimura.questions.new(title: '質問タイトル', description: '質問本文', wip: true)
    assert_not question2.will_be_published?

    question3 = kimura.questions.new(title: '質問タイトル', description: '質問本文', wip: false, published_at: '2022-01-01')
    assert_not question3.will_be_published?

    question4 = kimura.questions.new(title: '質問タイトル', description: '質問本文', wip: true, published_at: '2022-01-01')
    assert_not question4.will_be_published?
  end
end
