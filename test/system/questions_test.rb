# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/tag_helper'

class QuestionsTest < ApplicationSystemTestCase
  include TagHelper

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

  test 'show a resolved qestion' do
    question = questions(:question3)
    visit_with_auth question_path(question), 'kimura'
    assert_text '解決済'
  end

  test 'show a question' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'kimura'
    assert_equal 'テストの質問 | FBC', title
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
      find('.choices__inner').click
      find('#choices--js-choices-single-select-item-choice-12', text: 'sshdでパスワード認証を禁止にする').click
      click_button '更新する'
    end
    assert_text '質問を更新しました'

    assert_text 'テストの質問（修正）'
    assert_text 'テストの質問です。（修正）'
    assert_text 'sshdでパスワード認証を禁止にする'
  end

  test 'delete a question' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'kimura'
    accept_confirm do
      click_link '削除する'
    end
    assert_text '質問を削除しました。'
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
    within '.a-card.is-answer' do
      assert_text '内容修正'
      assert_text 'ベストアンサーにする'
      assert_text '削除する'
    end

    visit_with_auth questions_path(target: 'not_solved'), 'komagata'
    click_on 'テストの質問タイトル'
    within '.a-card.is-answer' do
      assert_text '内容修正'
      assert_text 'ベストアンサーにする'
      assert_text '削除する'
    end

    visit_with_auth questions_path(target: 'not_solved'), 'hatsuno'
    click_on 'テストの質問タイトル'
    within '.a-card.is-answer' do
      assert_no_text '内容修正'
      assert_no_text 'ベストアンサーにする'
      assert_no_text '削除する'
    end
  end

  test 'select box shows the practices that belong to a user course' do
    visit_with_auth questions_path(target: 'not_solved'), 'kimura'
    find('.choices__inner').click
    page_practices = page.all('.choices__item--choice').map(&:text).size
    course_practices = users(:kimura).course.practices.size + 1
    assert_equal page_practices, course_practices
  end

  test 'select practice title when push question button on practice page' do
    visit_with_auth "/practices/#{practices(:practice23).id}", 'hatsuno'
    click_on '質問する'
    assert_text '[Ruby] rubyをインストールする'
  end

  test 'Question display 25 items correctly' do
    visit_with_auth questions_path(target: 'solved'), 'kimura'
    50.times do |n|
      q = Question.create(title: "順番ばらつきテスト#{n}", description: "答え#{n}", user_id: 253_826_460, practice_id: 315_059_988)
      Answer.create(description: '正しい答え', user_id: 253_826_460, question_id: q.id, type: 'CorrectAnswer')
      Answer.create(description: '正しい答え2', user_id: 253_826_460, question_id: q.id)
    end

    visit questions_path(target: 'solved')

    assert_selector '.card-list-item', count: 25
    first('.pagination__item-link', text: '2').click
    assert_selector '.card-list-item', count: 25
  end

  test "mentor's watch-button is automatically on when new question is published" do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'メンターのみ投稿された質問が"Watch中"になるテスト'
      fill_in 'question[description]', with: 'メンターのみ投稿された質問が"Watch中"になるテスト'
      click_button '登録する'
    end
    assert_text '質問を作成しました。'

    visit_with_auth questions_path(target: 'not_solved'), 'komagata'
    click_link 'メンターのみ投稿された質問が"Watch中"になるテスト'
    assert_text '削除する'
    assert_text 'Watch中'
  end

  test "mentor's watch-button is not automatically on when new question is created as WIP" do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
      click_button 'WIP'
    end
    assert_text '質問をWIPとして保存しました。'

    visit_with_auth questions_path, 'komagata'
    click_link 'WIPタイトル'
    assert_text '削除する'
    assert_no_text 'Watch中'
  end

  test "mentor's watch-button is automatically on when WIP question is updated as published" do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
      click_button 'WIP'
    end
    assert_text '質問をWIPとして保存しました。'

    visit questions_path
    click_link 'WIPタイトル'
    assert_text '削除する'
    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたタイトル'
      fill_in 'question[description]', with: '更新された本文'
      click_button '質問を公開'
    end
    assert_text '質問を更新しました'

    visit_with_auth questions_path(target: 'not_solved'), 'komagata'
    click_link '更新されたタイトル'
    assert_text '削除する'
    assert_text 'Watch中'
  end

  test 'show number of comments' do
    visit_with_auth questions_path(target: 'not_solved'), 'kimura'
    assert_text 'コメント数表示テスト用の質問'
    element = all('.card-list-item').find { |component| component.has_text?('コメント数表示テスト用の質問') }
    within element do
      assert_selector '.a-meta', text: '（1）'
    end
  end

  test "show number of comments when comments don't exist" do
    visit_with_auth questions_path(target: 'not_solved'), 'kimura'
    assert_text 'テストの質問'

    element = all('.card-list-item').find { |component| component.has_text?('テストの質問') }
    within element do
      assert_selector '.a-meta.is-important', text: '（0）'
    end
  end

  test 'create a WIP question' do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'
  end

  test 'update a WIP question as WIP' do
    question = questions(:question_for_wip)
    visit_with_auth question_path(question), 'kimura'
    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたWIPタイトル'
      fill_in 'question[description]', with: '更新されたWIP本文'
    end
    click_button 'WIP'
    assert_selector '.a-title-label.is-wip', text: 'WIP'
  end

  test 'update a WIP question as published' do
    question = questions(:question_for_wip)
    visit_with_auth question_path(question), 'kimura'
    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたタイトル'
      fill_in 'question[description]', with: '更新された本文'
    end
    click_button '質問を公開'
    assert_selector '.a-title-label.is-solved.is-danger', text: '未解決'
  end

  test 'update a published question as WIP' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'kimura'
    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたWIPタイトル'
      fill_in 'question[description]', with: '更新されたWIP本文'
    end
    click_button 'WIP'
    assert_selector '.a-title-label.is-wip', text: 'WIP'
  end

  test 'show a WIP question on the All Q&A list page' do
    visit_with_auth questions_path, 'kimura'
    assert_text 'wipテスト用の質問(wip中)'
    element = all('.card-list-item').find { |component| component.has_text?('wipテスト用の質問(wip中)') }
    within element do
      assert_selector '.a-list-item-badge.is-wip', text: 'WIP'
    end
  end

  test 'not show a WIP question on the unsolved Q&A list page' do
    visit_with_auth questions_path(target: 'not_solved'), 'kimura'
    assert_no_text 'wipテスト用の質問(wip中)'
    assert_selector 'h2', text: 'Q&A'
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
    assert_selector '#not-solved-count', text: Question.not_solved.not_wip.where(practice_id: practices(:practice1).id).size
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

  test 'should not notify to chat after wip a question' do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'WIPタイトル'
      fill_in 'question[description]', with: 'WIP本文'
    end
    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button 'WIP'
    end

    assert_text '質問をWIPとして保存しました。'
    assert_no_match 'Message to Discord.', mock_log.to_s
  end

  test 'link to the question should appear and work correctly' do
    visit_with_auth new_question_path, 'kimura'
    fill_in 'question[title]', with: 'Questionに関連プラクティスを指定'
    fill_in 'question[description]', with: 'Questionに関連プラクティスを指定'
    find('.choices__inner').click
    find('#choices--js-choices-single-select-item-choice-6', text: 'Linuxのファイル操作の基礎を覚える').click
    click_button '登録する'
    assert_text 'Questionに関連プラクティスを指定'

    visit questions_path(target: 'not_solved')
    within first('.card-list-item-title__title') do
      assert_text 'Questionに関連プラクティスを指定'
    end
    within first('.a-meta.is-practice') do
      assert_text 'Linuxのファイル操作の基礎を覚える'
    end
    assert_link 'Linuxのファイル操作の基礎を覚える'
  end

  test 'show confirm dialog before delete' do
    visit_with_auth question_path(questions(:question8)), 'kimura'
    confirm_dialog = dismiss_confirm { click_link '削除する' }
    assert_equal '自己解決した場合は削除せずに回答を書き込んでください。本当に削除しますか？', confirm_dialog
  end

  test 'show a question without choosing practice' do
    question = questions(:question14)
    visit_with_auth question_path(question), 'kimura'
    assert_no_selector('.a-category-link')
    assert_text 'プラクティスを選択せずに登録したテストの質問'
  end

  test 'create a question without choosing practice' do
    visit_with_auth new_question_path, 'kimura'

    within 'form[name=question]' do
      click_button 'Remove item'
      fill_in 'question[title]', with: 'プラクティス指定のないテストの質問'
      fill_in 'question[description]', with: 'プラクティス指定のないテストの質問です。'
      click_button '登録する'
    end
    assert_text '質問を作成しました。'
    assert_no_selector('.a-category-link')
    assert_text 'プラクティス指定のないテストの質問'
  end

  test 'update a question without choosing practice' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'kimura'

    click_button '内容修正'
    within 'form[name=question]' do
      click_button 'Remove item'
      fill_in 'question[title]', with: 'テストの質問（修正）'
      fill_in 'question[description]', with: 'テストの質問です。（修正）'
      click_button '更新する'
    end
    assert_text '質問を更新しました'
    assert_selector '.a-category-link', text: ''
    assert_text 'テストの質問（修正）'
    assert_text 'テストの質問です。（修正）'
  end
end
