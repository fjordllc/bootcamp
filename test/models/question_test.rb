# frozen_string_literal: true

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  test '#will_be_published?' do
    kimura = users(:kimura)

    question = kimura.questions.new(title: '質問タイトル', description: '質問本文', wip: false)
    assert question.send(:will_be_published?)

    question = kimura.questions.new(title: '質問タイトル', description: '質問本文', wip: true)
    assert_not question.send(:will_be_published?)

    question = kimura.questions.new(title: '質問タイトル', description: '質問本文', wip: false, published_at: '2022-01-01')
    assert_not question.send(:will_be_published?)

    question = kimura.questions.new(title: '質問タイトル', description: '質問本文', wip: true, published_at: '2022-01-01')
    assert_not question.send(:will_be_published?)
  end

  test '#set_published_at' do
    kimura = users(:kimura)

    @question = kimura.questions.new(title: '質問タイトル', description: '質問本文', wip: false)
    travel_to Time.zone.local(2022, 1, 1, 0, 0, 0) do
      assert_equal Time.zone.now, @question.send(:set_published_at)
    end
  end
end
