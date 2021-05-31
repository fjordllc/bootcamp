# frozen_string_literal: true

require 'application_system_test_case'

class AnswersTest < ApplicationSystemTestCase
  setup { login_user 'komagata', 'testtest' }

  test 'answer form in questions/:id has comment tab and preview tab' do
    visit "/questions/#{questions(:question2).id}"
    wait_for_vuejs
    within('.thread-comment-form__tabs') do
      assert_text 'コメント'
      assert_text 'プレビュー'
    end
  end

  test 'post new comment for question' do
    visit "/questions/#{questions(:question2).id}"
    wait_for_vuejs
    within('.thread-comment-form__form') do
      fill_in('answer[description]', with: 'test')
    end
    page.all('.thread-comment-form__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
  end

  test 'edit answer form has comment tab and preview tab' do
    visit "/questions/#{questions(:question3).id}"
    wait_for_vuejs
    within('.thread-comment:first-child') do
      click_button '内容修正'
      assert_text 'コメント'
      assert_text 'プレビュー'
    end
  end

  test 'admin can edit and delete any questions' do
    visit "/questions/#{questions(:question1).id}"
    wait_for_vuejs
    answer_by_user = page.all('.thread-comment')[1]
    within answer_by_user do
      assert_text '内容修正'
      assert_text '削除'
    end
  end

  test "admin can resolve user's question" do
    visit "/questions/#{questions(:question2).id}"
    wait_for_vuejs
    assert_text 'ベストアンサーにする'
    accept_alert do
      click_button 'ベストアンサーにする'
    end
    assert_no_text 'ベストアンサーにする'
  end

  test 'delete best answer' do
    visit "/questions/#{questions(:question2).id}"
    wait_for_vuejs
    accept_alert do
      click_button 'ベストアンサーにする'
    end
    accept_alert do
      click_button 'ベストアンサーを取り消す'
    end
    assert_text 'ベストアンサーにする'
  end
end
