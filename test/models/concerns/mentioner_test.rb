# frozen_string_literal: true

require 'test_helper'

class MentionerTest < ActiveSupport::TestCase
  test 'where_mention for Answer' do
    answer = answers(:answer1)
    expected = 'machidaさんのQ&A「どのエディターを使うのが良いでしょうか」へのコメント'
    assert_equal expected, answer.where_mention
  end

  test 'where_mention for Comment' do
    comment = comments(:comment1)
    expected = 'komagataさんの日報「作業週1日目」へのコメント'
    assert_equal expected, comment.where_mention
  end

  test 'where_mention for Product' do
    product = products(:product2)
    expected = 'kimuraさんの提出物「OS X Mountain Lionをクリーンインストールする」'
    assert_equal expected, product.where_mention
  end

  test 'where_mention for Question' do
    question = questions(:question1)
    expected = 'machidaさんのQ&A「OS X Mountain Lionをクリーンインストールする」'
    assert_equal expected, question.where_mention
  end

  test 'where_mention for Report' do
    report = reports(:report1)
    expected = 'komagataさんの日報「作業週1日目」'
    assert_equal expected, report.where_mention
  end
end
