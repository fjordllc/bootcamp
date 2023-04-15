# frozen_string_literal: true

require 'application_system_test_case'

class Question::NotLoggedInTest < ApplicationSystemTestCase
  test 'meta discription is set when not logged-in user access show' do
    question = questions(:question1)
    visit "/questions/#{question.id}"
    assert_text "「#{question.title}」"
    assert_text 'このページの閲覧にはフィヨルドブートキャンプの入会が必要です'
    assert_selector "meta[name='description'][content='オンラインプログラミングスクール「フィヨルドブートキャンプ」のQ&A「#{question.title}」のページです。']", visible: false
  end
end
