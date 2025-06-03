# frozen_string_literal: true

require 'application_system_test_case'

class QuestionUiFeaturesTest < ApplicationSystemTestCase
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

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_question_path, 'kimura'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end

  test 'retain selected values when validation errors occur' do
    visit_with_auth new_question_path, 'komagata'
    within '.select-practices' do
      find('.choices__inner').click
      find('#choices--js-choices-practice-item-choice-12', text: 'sshdでパスワード認証を禁止にする').click
    end
    within '.select-user' do
      find('.choices__inner').click
      find('#choices--js-choices-user-item-choice-13', text: 'hatsuno').click
    end
    click_button 'WIP'

    assert_text '入力内容にエラーがありました'
    assert_text 'sshdでパスワード認証を禁止にする'
    assert_text 'hatsuno'
  end
end
