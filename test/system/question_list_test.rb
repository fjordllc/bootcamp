require "application_system_test_case"

class QuestionListTest < ApplicationSystemTestCase
  test "question page show message when question does not exist" do
    Question.delete_all
    login_user "machida", "testtest"
    visit questions_path

    assert_equal 0, all(".thread-list-item__title-link").size
    assert_text "質問はまだありません。"

    click_link "解決済み"

    assert_equal 0, all(".thread-list-item__title-link").size
    assert_text "質問はまだありません。"
  end

  test "question page show all of not solved questions or all of solved questions" do
    login_user "machida", "testtest"
    visit questions_path

    assert_equal Question.not_solved.size, all(".thread-list-item__title-link").size

    click_link "解決済み"

    assert_equal Question.solved.size, all(".thread-list-item__title-link").size
  end

  test "question page show message when target practice does not have solved questions or not solved question" do
    login_user "machida", "testtest"
    visit questions_path

    select "Terminalの基礎を覚える"

    assert_equal 0, all(".thread-list-item__title-link").size
    assert_text "質問はまだありません。"

    click_link "解決済み"

    assert_equal 0, all(".thread-list-item__title-link").size
    assert_text "質問はまだありません。"
  end

  test "question page show all of solved questions or all of solved questions with target practice" do
    login_user "machida", "testtest"
    visit questions_path

    select "OS X Mountain Lionをクリーンインストールする"

    target_practice = practices(:practice_1)

    assert_equal target_practice.questions.not_solved.size, all(".thread-list-item__title-link").size

    click_link "解決済み"

    assert_equal target_practice.questions.solved.size, all(".thread-list-item__title-link").size
  end

  test "practice's question page show message when target practice does not have solved questions or not solved question" do
    login_user "machida", "testtest"
    target_practice = practices(:practice_2)
    visit polymorphic_path([target_practice, :questions])

    assert_equal 0, all(".thread-list-item__title-link").size
    assert_text "質問はまだありません。"

    click_link "解決済み"

    assert_equal 0, all(".thread-list-item__title-link").size
    assert_text "質問はまだありません。"
  end

  test "practice's question page show all of solved questions or all of solved questions with target practice" do
    login_user "machida", "testtest"
    target_practice = practices(:practice_1)
    visit polymorphic_path([target_practice, :questions])

    assert_equal target_practice.questions.not_solved.size, all(".thread-list-item__title-link").size

    click_link "解決済み"

    assert_equal target_practice.questions.solved.size, all(".thread-list-item__title-link").size
  end

end
