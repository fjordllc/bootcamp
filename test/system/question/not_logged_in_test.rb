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

  test 'title of the title tag is truncated' do
    question = questions(:question16)
    visit question_path(question)
    assert_selector 'title', text: 'Q&A: 長いタイトルの質問長いタイトルの質問長いタイトルの質問長いタイト... | FBC', visible: false
  end

  test 'titles in og:title, og:description, twitter:description tags is not truncated' do
    question = questions(:question16)
    visit question_path(question)
    assert_selector "meta[property='og:title'][content='Q&A: 長いタイトルの質問長いタイトルの質問長いタイトルの質問長いタイトルの質問']",
                    visible: false
    assert_selector "meta[property='og:description'][content='オンラインプログラミングスクール「フィヨルドブートキャンプ」のQ&A「長いタイトルの質問長いタイトルの質問長いタイトルの質問長いタイトルの質問」のページです。']",
                    visible: false
    assert_selector "meta[name='twitter:description'][content='オンラインプログラミングスクール「フィヨルドブートキャンプ」のQ&A「長いタイトルの質問長いタイトルの質問長いタイトルの質問長いタイトルの質問」のページです。']",
                    visible: false
  end
end
