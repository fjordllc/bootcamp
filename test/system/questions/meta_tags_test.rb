# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mock_helper'

module Questions
  class MetaTagsTest < ApplicationSystemTestCase
    include MockHelper

    setup do
      mock_openai_chat_completion(content: 'Test AI response')
    end

    test 'show listing unsolved questions' do
      visit_with_auth questions_path(target: 'not_solved'), 'kimura'
      assert_equal '未解決のQ&A | FBC', title
    end

    test 'show listing solved questions' do
      visit_with_auth questions_path(target: 'solved'), 'kimura'
      assert_equal '解決済みのQ&A | FBC', title
    end

    test 'show listing all questions' do
      visit_with_auth questions_path, 'kimura'
      assert_equal '全てのQ&A | FBC', title
    end

    test 'show a question' do
      question = questions(:question8)
      visit_with_auth question_path(question), 'kimura'
      assert_equal 'Q&A: テストの質問 | FBC', title
    end

    test 'title of the title tag is truncated' do
      question = questions(:question16)
      visit_with_auth question_path(question), 'kimura'
      assert_selector 'title', text: 'Q&A: 長いタイトルの質問長いタイトルの質問長いタイトルの質問長いタイト... | FBC', visible: false
    end

    test 'titles in og:title, og:description, twitter:description tags is not truncated' do
      question = questions(:question16)
      visit_with_auth question_path(question), 'kimura'
      meta_title = '長いタイトルの質問長いタイトルの質問長いタイトルの質問長いタイトルの質問'
      meta_description = "kimura (キムラ タダシ)さんが投稿した、プラクティス「OS X Mountain Lionをクリーンインストールする」に関する質問「#{meta_title}」のページです。"
      assert_selector "meta[property='og:title'][content='Q&A: #{meta_title}']", visible: false
      assert_selector "meta[property='og:description'][content='#{meta_description}']", visible: false
      assert_selector "meta[name='twitter:description'][content='#{meta_description}']", visible: false
    end
  end
end
