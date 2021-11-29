# frozen_string_literal: true

require 'application_system_test_case'

class Question::TagsTest < ApplicationSystemTestCase
  test 'search questions by tag' do
    visit_with_auth questions_url, 'kimura'
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
    visit_with_auth question_path(questions(:question2)), 'komagata'
    find('.tag-links__item-edit').click
    tag_input = find('.ti-new-tag-input')
    tag_input.set '追加タグ'
    tag_input.native.send_keys :return
    click_on '保存'
    wait_for_vuejs
    assert_text '追加タグ'
  end
end
