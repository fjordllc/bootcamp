# frozen_string_literal: true

require 'application_system_test_case'

class Question::NotificationsTest < ApplicationSystemTestCase
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
    click_link '内容修正'
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
    click_link '内容修正'

    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button '質問を公開'
      assert_text '質問を更新しました'
    end

    assert_match 'Message to Discord.', mock_log.to_s
  end
end
