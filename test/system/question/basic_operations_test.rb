# frozen_string_literal: true

require 'application_system_test_case'

class Question::BasicOperationsTest < ApplicationSystemTestCase
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

  test 'show a resolved question' do
    question = questions(:question3)
    visit_with_auth question_path(question), 'kimura'
    assert_text '解決済'
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

  test 'create a question' do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'テストの質問'
      fill_in 'question[description]', with: 'テストの質問です。'
      click_button '登録する'
    end
    assert_text '質問を作成しました。'
  end

  test 'update a question' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'kimura'

    click_link '内容修正'
    fill_in 'question[title]', with: 'テストの質問（修正）'
    fill_in 'question[description]', with: 'テストの質問です。（修正）'
    within '.select-practices' do
      find('.choices__inner').click
      find('#choices--js-choices-practice-item-choice-12', text: 'sshdでパスワード認証を禁止にする').click
    end
    click_button '更新する'

    assert_text 'テストの質問（修正）'
    assert_text 'テストの質問です。（修正）'
    assert_selector 'a.a-category-link', text: 'sshdでパスワード認証を禁止にする'
    assert_selector 'a.a-side-nav__title-link', text: 'sshdでパスワード認証を禁止にする'
    assert_selector 'div.a-side-nav__item-title', text: 'プラクティス「sshdでパスワード認証を禁止にする」に関する質問'
  end

  test 'delete a question' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'kimura'
    assert_text '削除申請'
  end
end
