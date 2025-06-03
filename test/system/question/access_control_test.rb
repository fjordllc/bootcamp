# frozen_string_literal: true

require 'application_system_test_case'

class QuestionAccessControlTest < ApplicationSystemTestCase
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

  test 'users except for admin or mentor cannot change the questioner' do
    visit_with_auth new_question_path, 'hatsuno'
    assert_no_selector('.select-user')
  end

  test 'admin can change the questioner when creating a new question' do
    visit_with_auth new_question_path, 'adminonly'
    fill_in 'question[title]', with: 'テストの質問'
    fill_in 'question[description]', with: 'テストの質問です。'
    within '.select-user' do
      find('.choices__inner').click
      find('#choices--js-choices-user-item-choice-13', text: 'hatsuno').click
    end
    click_button '登録する'
    assert_selector '.a-user-name', text: 'hatsuno (ハツノ シンジ)'
  end

  test 'mentor can change the questioner when editing a question' do
    question = questions(:question8)
    visit_with_auth question_path(question), 'mentormentaro'
    click_link '内容修正'
    within '.select-user' do
      find('.choices__inner').click
      find('#choices--js-choices-user-item-choice-13', text: 'hatsuno').click
    end
    click_button '更新する'
    assert_selector '.a-user-name', text: 'hatsuno (ハツノ シンジ)'
  end
end
