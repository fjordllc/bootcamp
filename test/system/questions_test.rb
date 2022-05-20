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
      find('.choices__inner').click
      find('#choices--js-choices-single-select-item-choice-44', text: 'sshdでパスワード認証を禁止にする').click
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
    assert_text 'kimuraさんから質問「タイトルtest」が投稿されました。'

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
    assert_no_text 'kimuraさんから質問「タイトルtest」が投稿されました。'
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

    visit_with_auth questions_path, 'komagata'
    click_on 'テストの質問タイトル'
    within '.a-card.is-answer' do
      assert_text '内容修正'
      assert_text 'ベストアンサーにする'
      assert_text '削除する'
    end

    visit_with_auth questions_path, 'hatsuno'
    click_on 'テストの質問タイトル'
    within '.a-card.is-answer' do
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

    visit_with_auth questions_path, 'komagata'
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

    visit_with_auth questions_path(all: 'true'), 'komagata'
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

    visit questions_path(all: 'true')
    click_link 'WIPタイトル'
    assert_text '削除する'
    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたタイトル'
      fill_in 'question[description]', with: '更新された本文'
      click_button '質問を公開'
    end
    assert_text '質問を更新しました'

    visit_with_auth questions_path, 'komagata'
    click_link '更新されたタイトル'
    assert_text '削除する'
    assert_text 'Watch中'
  end

  test 'show number of comments' do
    visit_with_auth questions_path, 'kimura'
    assert_text 'コメント数表示テスト用の質問'
    element = all('.card-list-item').find { |component| component.has_text?('コメント数表示テスト用の質問') }
    within element do
      assert_selector '.a-meta', text: '（1）'
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
    visit_with_auth questions_path(all: 'true'), 'kimura'
    assert_text 'wipテスト用の質問(wip中)'
    element = all('.card-list-item').find { |component| component.has_text?('wipテスト用の質問(wip中)') }
    within element do
      assert_selector '.card-list-item-title__icon.is-wip', text: 'WIP'
    end
  end

  test 'not show a WIP question on the unsolved Q&A list page' do
    visit_with_auth questions_path, 'kimura'
    assert_no_text 'wipテスト用の質問(wip中)'
    assert_text '未解決の質問一覧'
  end

  test "visit user profile page when clicked on user's name on question" do
    visit_with_auth questions_path, 'kimura'
    assert_text '質問のタブの作り方'
    click_link 'hatsuno (Hatsuno Shinji)', match: :first
    assert_text 'プロフィール'
    assert_text 'Hatsuno Shinji（ハツノ シンジ）'
  end

  test 'show number of unanswered questions' do
    visit_with_auth questions_path(practice_id: practices(:practice1).id), 'komagata'
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
end
