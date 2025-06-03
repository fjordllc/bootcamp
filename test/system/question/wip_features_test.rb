# frozen_string_literal: true

require 'application_system_test_case'

class Question::WipFeaturesTest < ApplicationSystemTestCase
  test 'create a question through wip' do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'テストの質問'
      fill_in 'question[description]', with: 'テストの質問です。'
      click_button 'WIP'
    end
    assert_text '質問をWIPとして保存しました。'

    click_button '質問を公開'
    assert_text '質問を更新しました。'

    click_link '内容修正'
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました。'
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
    click_link '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたWIPタイトル'
      fill_in 'question[description]', with: '更新されたWIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました'
  end

  test 'update a WIP question as published' do
    question = questions(:question_for_wip)
    visit_with_auth question_path(question), 'kimura'
    click_link '内容修正'
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
    click_link '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: '更新されたWIPタイトル'
      fill_in 'question[description]', with: '更新されたWIP本文'
    end
    click_button 'WIP'
    assert_text '質問をWIPとして保存しました'
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
end
