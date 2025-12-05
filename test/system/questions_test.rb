# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mock_helper'

class QuestionsTest < ApplicationSystemTestCase
  include MockHelper

  setup do
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
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

  test 'admin can update and delete any questions' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'komagata'
    within '.page-content' do
      assert_text '内容修正'
      assert_text '削除'
    end
  end

  test 'not admin or not question author can not delete any questions' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'hatsuno'
    within '.page-content' do
      assert_no_text '内容修正'
      assert_no_text '削除'
    end
  end

  test 'Question display 25 items correctly' do
    # 既存の解決済み質問数を確認し、26件になるよう必要な数だけ作成
    existing_count = Question.solved.count
    needed = [26 - existing_count, 0].max

    needed.times do |n|
      q = Question.create(title: "ページネーションテスト#{n}", description: "答え#{n}", user_id: 253_826_460, practice_id: 315_059_988)
      Answer.create(description: '正しい答え', user_id: 253_826_460, question_id: q.id, type: 'CorrectAnswer')
    end

    visit_with_auth questions_path(target: 'solved'), 'kimura'

    assert_selector '.card-list-item', count: 25
    first('.pagination__item-link', text: '2').click
    assert_selector '.card-list-item', count: 1
  end

  test "visit user profile page when clicked on user's name on question" do
    visit_with_auth questions_path(target: 'not_solved'), 'kimura'
    assert_text '質問のタブの作り方'
    click_link 'hatsuno (Hatsuno Shinji)', match: :first
    assert_text 'プロフィール'
    assert_text 'Hatsuno Shinji（ハツノ シンジ）'
  end

  test 'show number of unanswered questions' do
    visit_with_auth questions_path(practice_id: practices(:practice1).id, target: 'not_solved'), 'komagata'
    assert_selector '.not-solved-count', text: Question.not_solved.not_wip.where(practice_id: practices(:practice1).id).size
  end

  test 'notify to chat after publish a question' do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'タイトル'
      fill_in 'question[description]', with: '本文'
    end
    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button '登録する'
    end

    assert_text '質問を作成しました。'
    assert_match 'Message to Discord.', mock_log.to_s
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_question_path, 'kimura'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end
end
