# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/tag_helper'

class Question::TaggingTest < ApplicationSystemTestCase
  include TagHelper

  test 'alert when enter tag with space on creation question' do
    visit_with_auth new_question_path, 'kimura'
    ['半角スペースは 使えない', '全角スペースも　使えない'].each do |tag|
      fill_in_tag_with_alert tag
    end
    fill_in_tag 'foo'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'test title'
      fill_in 'question[description]', with: 'test body'
      click_button '登録する'
    end
    assert_equal ['foo'], all('.tag-links__item-link').map(&:text)
  end

  test 'alert when enter one dot only tag on creation question' do
    visit_with_auth new_question_path, 'kimura'
    fill_in_tag_with_alert '.'
    fill_in_tag 'foo'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'test title'
      fill_in 'question[description]', with: 'test body'
      click_button '登録する'
    end
    assert_equal ['foo'], all('.tag-links__item-link').map(&:text)
  end

  test 'alert when enter tag with space on update question' do
    question = questions(:question3)
    visit_with_auth "/questions/#{question.id}", 'komagata'
    find('.tag-links__item-edit').click
    tag_input = first('.tagify__input')
    accept_alert do
      tag_input.set "半角スペースは 使えない\t"
    end
    click_button '保存する'
    find('.tag-links__item-edit').click
    tag_input = first('.tagify__input')
    accept_alert do
      tag_input.set "全角スペースも　使えない\t"
    end
    click_button '保存する'
    assert_equal question.tag_list.sort, all('.tag-links__item-link').map(&:text).sort
  end

  test 'alert when enter one dot only tag on update page' do
    question = questions(:question3)
    visit_with_auth "/questions/#{question.id}", 'komagata'
    find('.tag-links__item-edit').click
    tag_input = first('.tagify__input')
    accept_alert do
      tag_input.set ".\t"
    end
    click_button '保存する'
    assert_equal question.tag_list.sort, all('.tag-links__item-link').map(&:text).sort
  end
end
