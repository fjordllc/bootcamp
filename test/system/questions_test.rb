# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/tag_helper'

class QuestionsTest < ApplicationSystemTestCase
  include TagHelper

  setup do
    login_user 'kimura', 'testtest'
  end

  test 'show listing unsolved questions' do
    visit questions_path
    assert_equal '未解決の質問一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing solved questions' do
    visit questions_path(solved: 'true')
    assert_equal '解決済みの質問一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing all questions' do
    visit questions_path(all: 'true')
    assert_equal '全ての質問 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show a resolved qestion' do
    question = questions(:question3)
    visit question_path(question)
    assert_text '解決済'
  end

  test 'show a question' do
    question = questions(:question8)
    visit question_path(question)
    assert_equal 'テストの質問 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'create a question' do
    visit new_question_path
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'テストの質問'
      fill_in 'question[description]', with: 'テストの質問です。'
      click_button '登録する'
    end
    assert_text '質問を作成しました。'
  end

  test 'update a question' do
    question = questions(:question8)
    visit question_path(question)
    wait_for_vuejs
    click_button '内容修正'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'テストの質問（修正）'
      fill_in 'question[description]', with: 'テストの質問です。（修正）'
      click_button '更新する'
    end
    assert_text 'テストの質問（修正）'
    assert_text 'テストの質問です。（修正）'
  end

  test 'delete a question' do
    question = questions(:question8)
    visit question_path(question)
    wait_for_vuejs
    accept_confirm do
      find('.js-delete').click
    end
    assert_no_text 'kimura'
  end

  test 'delete question with notification' do
    login_user 'kimura', 'testtest'
    visit '/questions'
    click_link '質問する'
    fill_in 'question[title]', with: 'タイトルtest'
    fill_in 'question[description]', with: '内容test'

    click_button '登録する'
    assert_text '質問を作成しました。'

    login_user 'komagata', 'testtest'
    visit '/notifications'
    assert_text 'kimuraさんから質問がありました。'

    login_user 'kimura', 'testtest'
    visit '/questions'
    click_on 'タイトルtest'
    wait_for_vuejs
    accept_confirm do
      click_button '削除'
    end
    assert_no_text 'タイトルtest'

    login_user 'komagata', 'testtest'
    visit '/notifications'
    assert_no_text 'kimuraさんから質問がありました。'
  end

  test 'admin can update and delete any questions' do
    login_user 'komagata', 'testtest'
    question = questions(:question8)
    visit question_path(question)
    within '.thread__inner' do
      assert_text '内容修正'
      assert_text '削除'
    end
  end

  test 'search questions by tag' do
    visit questions_url
    click_on '質問する'
    tag_list = ['tag1',
                'ドットつき.タグ',
                'ドットが.2つ以上の.タグ',
                '.先頭がドット',
                '最後がドット.']
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'tagテストの質問'
      fill_in 'question[description]', with: 'tagテストの質問です。'
      tag_input = find('.ti-new-tag-input')
      tag_list.each do |tag|
        tag_input.set tag
        tag_input.native.send_keys :return
      end
      click_button '登録する'
    end
    click_on 'Q&A', match: :first

    tag_list.each do |tag|
      assert_text tag
      click_on tag, match: :first
      assert_text 'tagテストの質問'
      assert_no_text 'どのエディターを使うのが良いでしょうか'
    end
  end

  test 'update tags without page transitions' do
    login_user 'komagata', 'testtest'
    visit question_path(questions(:question2))
    find('.tag-links__item-edit').click
    tag_input = find('.ti-new-tag-input')
    tag_input.set '追加タグ'
    tag_input.native.send_keys :return
    click_on '保存'
    wait_for_vuejs
    assert_text '追加タグ'
  end

  test 'alert when enter tag with space on creation page' do
    visit new_page_path

    # この次に assert_alert_when_enter_one_dot_only_tag を追加しても、
    # 空白を入力したalertが発生し、ドットのみのalertが発生するテストにならない
    assert_alert_when_enter_tag_with_space
  end

  test 'alert when enter one dot only tag on creation page' do
    visit new_page_path

    assert_alert_when_enter_one_dot_only_tag
  end

  test 'alert when enter tag with space on update page' do
    visit "/pages/#{pages(:page1).id}"
    find('.tag-links__item-edit').click

    assert_alert_when_enter_tag_with_space
  end

  test 'alert when enter one dot only tag on update page' do
    visit "/pages/#{pages(:page1).id}"
    find('.tag-links__item-edit').click

    assert_alert_when_enter_one_dot_only_tag
  end
end
