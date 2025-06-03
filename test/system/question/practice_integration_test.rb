# frozen_string_literal: true

require 'application_system_test_case'

class Question::PracticeIntegrationTest < ApplicationSystemTestCase
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

  test 'link to the question should appear and work correctly' do
    visit_with_auth new_question_path, 'kimura'
    fill_in 'question[title]', with: 'Questionに関連プラクティスを指定'
    fill_in 'question[description]', with: 'Questionに関連プラクティスを指定'
    within '.select-practices' do
      find('.choices__inner').click
      find('#choices--js-choices-practice-item-choice-7', text: 'Linuxのファイル操作の基礎を覚える').click
    end
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

    click_link '内容修正'
    within 'form[name=question]' do
      click_button 'Remove item'
      fill_in 'question[title]', with: 'テストの質問（修正）'
      fill_in 'question[description]', with: 'テストの質問です。（修正）'
      click_button '更新する'
    end
    assert_text '質問を更新しました'
    assert_no_selector('.a-category-link')
    assert_text 'テストの質問（修正）'
    assert_text 'テストの質問です。（修正）'
  end

  test 'show practice questions and the link works' do
    question = questions(:question7)
    visit_with_auth question_path(question), 'kimura'

    find('.a-side-nav').click_link 'OS X Mountain Lionをクリーンインストールする'
    find('h1') { assert_text 'OS X Mountain Lionをクリーンインストールする' }
    go_back

    find('.a-side-nav').click_link 'どのエディターを使うのが良いでしょうか'
    find('h1') { assert_text 'どのエディターを使うのが良いでしょうか' }
    go_back

    find('.a-side-nav').click_link '全て見る'
    find('.choices__item') { assert_text 'OS X Mountain Lionをクリーンインストールする' }
    go_back

    within '.a-side-nav' do
      assert_no_text question.title
      assert_no_text 'wipテスト用の質問(wip中)'
    end
  end
end
