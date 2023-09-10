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

  test 'create a question through wip' do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'テストの質問'
      fill_in 'question[description]', with: 'テストの質問です。'
      click_button 'WIP'
    end
    assert_text '質問をWIPとして保存しました。'

    click_button '内容修正'
    click_button '質問を公開'
    assert_text '質問を公開しました。'

    click_button '内容修正'
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'
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
    assert_text 'テストの質問（修正）'
    assert_text 'テストの質問です。（修正）'
    assert_selector 'a.a-category-link', text: 'sshdでパスワード認証を禁止にする'
    assert_selector 'a.page-nav__title-link', text: 'sshdでパスワード認証を禁止にする'
    assert_selector 'div.page-nav__item-title', text: 'プラクティス「sshdでパスワード認証を禁止にする」に関する質問'
  end

  test 'admin can update and delete any questions' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'adminonly'
    within '.page-content' do
      assert_text '内容修正'
      assert_text '削除'
    end
  end

  test 'mentor can update and delete any questions' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'mentormentaro'
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

  test 'alert when enter tag with space on creation question' do
    visit_with_auth new_question_path, 'kimura'
    ['半角スペースは 使えない', '全角スペースも　使えない'].each do |tag|
      fill_in_tag_with_alert tag
    end
    fill_in_tag 'foo'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'test title'
      fill_in 'question[description]', with: 'test body'
      click_button '登録する'
    end
    assert_equal ['foo'], all('.tag-links__item-link').map(&:text)
  end

  test 'alert when enter one dot only tag on creation question' do
    visit_with_auth new_question_path, 'kimura'
    fill_in_tag_with_alert '.'
    fill_in_tag 'foo'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'test title'
      fill_in 'question[description]', with: 'test body'
      click_button '登録する'
    end
    assert_equal ['foo'], all('.tag-links__item-link').map(&:text)
  end

  test 'alert when enter tag with space on update question' do
    question = questions(:question3)
    visit_with_auth "/questions/#{question.id}", 'komagata'
    find('.tag-links__item-edit').click
    tag_input = first('.ti-new-tag-input')
    accept_alert do
      tag_input.set "半角スペースは 使えない\t"
    end
    tag_input = first('.ti-new-tag-input')
    accept_alert do
      tag_input.set "全角スペースも　使えない\t"
    end
    click_button '保存する'
    assert_equal question.tag_list.sort, all('.tag-links__item-link').map(&:text).sort
  end

  test 'alert when enter one dot only tag on update page' do
    question = questions(:question3)
    visit_with_auth "/questions/#{question.id}", 'komagata'
    find('.tag-links__item-edit').click
    tag_input = first('.ti-new-tag-input')
    accept_alert do
      tag_input.set ".\t"
    end
    click_button '保存する'
    assert_equal question.tag_list.sort, all('.tag-links__item-link').map(&:text).sort
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
    assert_text 'rubyをインストールする'
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
    assert_text '削除申請'
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

  test 'notify to chat after publish a question from WIP' do
    question = questions(:question_for_wip)
    visit_with_auth question_path(question), 'kimura'
    click_button '内容修正'

    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button '質問を公開'
      assert_text '質問を更新しました'
    end

    assert_match 'Message to Discord.', mock_log.to_s
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

  test 'show practice questions and the link works' do
    question = questions(:question7)
    visit_with_auth question_path(question), 'kimura'

    find('.page-nav').click_link 'OS X Mountain Lionをクリーンインストールする'
    find('h1') { assert_text 'OS X Mountain Lionをクリーンインストールする' }
    go_back

    find('.page-nav').click_link 'どのエディターを使うのが良いでしょうか'
    find('h1') { assert_text 'どのエディターを使うのが良いでしょうか' }
    go_back

    find('.page-nav').click_link '全て見る'
    find('.choices__item') { assert_text 'OS X Mountain Lionをクリーンインストールする' }
    go_back

    within '.page-nav' do
      assert_no_text question.title
      assert_no_text 'wipテスト用の質問(wip中)'
    end
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_question_path, 'kimura'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end

  test 'using file uploading by file selection dialogue in textarea at editing question' do
    question = questions(:question3)
    visit_with_auth "/questions/#{question.id}", 'komagata'
    click_button '内容修正'

    element = first('.a-file-insert')
    within element do
      assert_selector 'input.js-question-file-input', visible: false
    end
    assert_equal '.js-question-file-input', find('textarea.a-text-input')['data-input']
  end
end
