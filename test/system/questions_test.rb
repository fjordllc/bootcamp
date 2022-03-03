# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/tag_helper'

class QuestionsTest < ApplicationSystemTestCase
  include TagHelper

  test 'show listing unsolved questions' do
    visit_with_auth questions_path, 'kimura'
    assert_equal '未解決の質問一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing solved questions' do
    visit_with_auth questions_path(solved: 'true'), 'kimura'
    assert_equal '解決済みの質問一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing all questions' do
    visit_with_auth questions_path(all: 'true'), 'kimura'
    assert_equal '全ての質問 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show a resolved qestion' do
    question = questions(:question3)
    visit_with_auth question_path(question), 'kimura'
    assert_text '解決済'
  end

  test 'show a question' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'kimura'
    assert_equal 'テストの質問 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
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

    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'テストの質問（修正）'
      fill_in 'question[description]', with: 'テストの質問です。（修正）'
      select 'sshdでパスワード認証を禁止にする', from: 'question[practice]'
      click_button '更新する'
    end
    assert_text '質問を更新しました'

    assert_text 'テストの質問（修正）'
    assert_text 'テストの質問です。（修正）'
    assert_text 'sshdでパスワード認証を禁止にする'
  end

  test 'update question for practice without questioner\'s course' do
    visit_with_auth edit_current_user_path, 'kimura'

    visit new_question_path
    within 'form[name=question]' do
      fill_in 'question[title]', with: '質問者のコースにはないプラクティスの質問を編集できるかのテスト'
      fill_in 'question[description]', with: '編集できれば期待通りの動作'
      select 'iOSへのビルドと固有の問題', from: 'question[practice_id]'
      click_button '登録する'
    end
    assert_text '質問を作成しました。'

    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '質問者のコースにはないプラクティスの質問でも'
      fill_in 'question[description]', with: '編集できる'
      select 'iOSへのビルドと固有の問題', from: 'question[practice]'
      click_button '更新する'
    end
    assert_text '質問を更新しました'

    assert_text '質問者のコースにはないプラクティスの質問でも'
    assert_text '編集できる'
    assert_text 'iOSへのビルドと固有の問題'
  end

  test 'delete a question' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'kimura'
    accept_confirm do
      click_link '削除する'
    end
    assert_text '質問を削除しました。'
  end

  test 'delete question with notification' do
    visit_with_auth '/questions', 'kimura'
    click_link '質問する'
    fill_in 'question[title]', with: 'タイトルtest'
    fill_in 'question[description]', with: '内容test'

    assert_difference -> { Question.count }, 1 do
      click_button '登録する'
      assert_text '質問を作成しました。'
    end

    visit_with_auth '/notifications', 'komagata'
    assert_text 'yameoさんが退会しました。'
    assert_text 'kimuraさんから質問がありました。'

    visit_with_auth '/questions', 'kimura'
    click_on 'タイトルtest'
    assert_difference -> { Question.count }, -1 do
      accept_confirm do
        click_link '削除する'
      end
      assert_text '質問を削除しました。'
    end

    visit_with_auth '/notifications', 'komagata'
    assert_text 'yameoさんが退会しました。'
    assert_no_text 'kimuraさんから質問がありました。'
  end

  test 'admin can update and delete any questions' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'komagata'
    within '.thread__inner' do
      assert_text '内容修正'
      assert_text '削除'
    end
  end

  test 'not admin or not question author can not delete any questions' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'hatsuno'
    within '.thread__inner' do
      assert_no_text '内容修正'
      assert_no_text '削除'
    end
  end

  test 'alert when enter tag with space on creation page' do
    visit_with_auth new_page_path, 'kimura'

    # この次に assert_alert_when_enter_one_dot_only_tag を追加しても、
    # 空白を入力したalertが発生し、ドットのみのalertが発生するテストにならない
    assert_alert_when_enter_tag_with_space
  end

  test 'alert when enter one dot only tag on creation page' do
    visit_with_auth new_page_path, 'kimura'
    assert_alert_when_enter_one_dot_only_tag
  end

  test 'alert when enter tag with space on update page' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'kimura'
    find('.tag-links__item-edit').click
    assert_alert_when_enter_tag_with_space
  end

  test 'alert when enter one dot only tag on update page' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'kimura'
    find('.tag-links__item-edit').click
    assert_alert_when_enter_one_dot_only_tag
  end

  test 'permission decision best answer' do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'テストの質問タイトル'
      fill_in 'question[description]', with: 'テストの質問です。'
      click_button '登録する'
    end
    fill_in 'answer[description]', with: 'アンサーテスト'
    click_button 'コメントする'
    within '.thread-comment__body' do
      assert_text '内容修正'
      assert_text 'ベストアンサーにする'
      assert_text '削除する'
    end

    visit_with_auth questions_path, 'komagata'
    click_on 'テストの質問タイトル'
    within '.thread-comment__body' do
      assert_text '内容修正'
      assert_text 'ベストアンサーにする'
      assert_text '削除する'
    end

    visit_with_auth questions_path, 'hatsuno'
    click_on 'テストの質問タイトル'
    within '.thread-comment__body' do
      assert_no_text '内容修正'
      assert_no_text 'ベストアンサーにする'
      assert_no_text '削除する'
    end
  end

  test 'select box shows the practices that belong to a user course' do
    visit_with_auth questions_path, 'kimura'
    find('.multiselect').click
    selects_size = users(:kimura).course.practices.size + 1
    assert_selector '.multiselect__element', count: selects_size
  end

  test 'select practice title when push question button on practice page' do
    visit_with_auth "/practices/#{practices(:practice23).id}", 'hatsuno'
    click_on '質問する'
    assert_text '[Ruby] rubyをインストールする'
  end

  test 'Question display 25 items correctly' do
    visit_with_auth questions_path(solved: 'true'), 'kimura'
    50.times do |n|
      q = Question.create(title: "順番ばらつきテスト#{n}", description: "答え#{n}", user_id: 253_826_460, practice_id: 315_059_988)
      Answer.create(description: '正しい答え', user_id: 253_826_460, question_id: q.id, type: 'CorrectAnswer')
      Answer.create(description: '正しい答え2', user_id: 253_826_460, question_id: q.id)
    end

    visit questions_path(solved: 'true')

    assert_selector '.thread-list-item', count: 25
    first('.pagination__item-link', text: '2').click
    assert_selector '.thread-list-item', count: 25
  end

  test 'mentor create a question' do
    visit_with_auth new_question_path, 'komagata'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'メンターのみ投稿された質問が"Watch中"になるテスト'
      fill_in 'question[description]', with: 'メンターのみ投稿された質問が"Watch中"になるテスト'
      click_button '登録する'
    end
    assert_text 'Watch中'
  end

  test 'show number of comments' do
    visit_with_auth questions_path, 'kimura'
    assert_text 'コメント数表示テスト用の質問'
    element = all('.thread-list-item').find { |component| component.has_text?('コメント数表示テスト用の質問') }
    within element do
      assert_selector '.thread-list-item-comment__count', text: '（1）'
    end
  end
end
