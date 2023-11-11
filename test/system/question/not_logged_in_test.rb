# frozen_string_literal: true

require 'application_system_test_case'

class Question::NotLoggedInTest < ApplicationSystemTestCase
  test 'not logged-in user can access show and meta description is set' do
    question = questions(:question1)
    visit question_path(question)
    assert_text "「#{question.title}」"
    assert_text 'このページの閲覧にはフィヨルドブートキャンプの入会が必要です'
    assert_selector "meta[name='description'][content='オンラインプログラミングスクール「フィヨルドブートキャンプ」のQ&A「#{question.title}」のページです。']", visible: false
  end
end
