# frozen_string_literal: true

require 'test_helper'

class PracticeDisplayTest < ActionDispatch::IntegrationTest
  GRANT_STATUS_MESSAGE = '進捗のステータス変更は、給付金コースのプラクティス側で行ってください。'
  GRANT_SUBMISSION_MESSAGE = '提出・修了は、給付金コースのプラクティス側で行ってください。'

  test 'shows practice' do
    login('hatsuno')
    get practice_path(practices(:practice1))
    assert_select 'title', text: 'プラクティス OS X Mountain Lionをクリーンインストールする | FBC'
  end

  test 'shows practice quiz as the primary next action' do
    practice = practices(:practice3)
    quiz = PracticeQuiz.create!(practice:, published: false)
    question = quiz.practice_quiz_questions.create!(
      question_type: :single_choice, body: '正しいものを選んでください。', explanation: '解説です。', position: 1, published: false
    )
    question.practice_quiz_choices.create!(body: '正解', correct: true, position: 1)
    question.practice_quiz_choices.create!(body: '不正解', correct: false, position: 2)
    question.update!(published: true)
    quiz.update!(published: true)

    login('kimura')
    get practice_path(practice)
    assert_select 'a.is-primary[href=?]', practice_practice_quiz_path(practice), text: '理解度テストに進む'
  end

  test 'shows links to all practices with same category' do
    user = users(:hatsuno)
    practice = practices(:practice1)
    login('hatsuno')
    get practice_path(practice)
    titles = css_select('.page-nav__item-link').map { |link| link.text.strip }
    practice.category(user.course).practices.each do |category_practice|
      assert_includes titles, category_practice.title
    end
  end

  test 'shows other practices in order' do
    login('kimura')
    get practice_path(practices(:practice2))
    titles = css_select('.page-nav__item-link').map { |link| link.text.strip }
    assert_operator titles.rindex('Terminalの基礎を覚える'), :<, titles.rindex('Debianをインストールする')
  end

  test 'shows link to create product only to user who has to submit product' do
    login('machida')
    get practice_path(practices(:practice1))
    assert_select 'a', text: '提出物を作る'

    login('mentormentaro')
    get practice_path(practices(:practice1))
    assert_response :success
    assert_select 'a', text: '提出物を作る', count: 0
  end

  test 'shows last updated user icon' do
    login('hajime')
    get practice_path(practices(:practice55))
    assert_select '.thread-header__user-icon-link img[alt=?]', 'komagata (Komagata Masaki): 管理者、メンター'
  end

  test 'shows all questions by default on questions tab' do
    practice = practices(:practice1)
    login('komagata')
    get "/practices/#{practice.id}/questions"
    assert_equal 12, practice.questions.length
    assert_includes response.body, '質問 （12）'
    %w[全ての質問 解決済み 未解決].each { |label| assert_includes response.body, label }
  end

  test 'shows guidance to grant course practice on source practice for grant course user' do
    login('grant-course')
    get practice_path(practices(:practice23))
    assert_select 'a[href=?]', practice_path(practices(:practice64)), text: '給付金コースへ移動する'
    assert_includes response.body, GRANT_STATUS_MESSAGE
    assert_includes response.body, GRANT_SUBMISSION_MESSAGE
    [
      '提出の前に、提出時の注意点を確認しよう', '提出物を作成し提出し、メンターから確認をもらったら', 'このプラクティスを修了にしてください。',
      'このプラクティスに提出物はありません。', '修了条件をクリアしたら修了にしてください。'
    ].each { |text| assert_not_includes response.body, text }
  end

  test 'shows normal status buttons on source practice for non grant course user' do
    login('kimura')
    get practice_path(practices(:practice23))
    assert_includes response.body, 'rubyをインストールする'
    assert_normal_status_buttons
    assert_not_includes response.body, GRANT_SUBMISSION_MESSAGE
    assert_select 'a', text: '給付金コース', count: 0
  end

  test 'shows normal status buttons on grant course practice for grant course user' do
    login('grant-course')
    get practice_path(practices(:practice64))
    assert_normal_status_buttons
  end

  private

  def login(login_name)
    post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
  end

  def assert_normal_status_buttons
    assert_select '.practice-status-buttons__button'
    assert_select 'a', text: '給付金コースへ移動する', count: 0
    assert_not_includes response.body, GRANT_STATUS_MESSAGE
  end
end
