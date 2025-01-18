# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::CodingTestsTest < ApplicationSystemTestCase
  test 'show listing coding_tests' do
    visit_with_auth '/mentor/coding_tests', 'mentormentaro'
    assert_equal 'コーディングテスト | FBC', title
  end

  test 'create a coding_test' do
    visit_with_auth '/mentor/coding_tests/new', 'mentormentaro'
    within 'form[name=coding_test]' do
      # choice a practice from the dropdown
      first('.choices__item--selectable').click
      first('#choices--js-choices-single-select-item-choice-3', visible: false).click

      fill_in 'coding_test[title]', with: 'テストのコーディングテスト'
      select 'javascript', from: 'coding_test[language]'
      fill_in 'coding_test[description]', with: 'テストのコーディングテストの説明'

      first('.add_fields').click

      within first('.test-case') do
        first('.test_case_input').set('入力')
        first('.test_case_output').set('出力')
      end
      click_button '登録する'
    end
    assert_selector '.page-content-header__title', text: 'テストのコーディングテスト'
  end

  test 'update a coding_test' do
    coding_test = coding_tests(:coding_test1)
    visit_with_auth "/mentor/coding_tests/#{coding_test.id}/edit", 'mentormentaro'
    within 'form[name=coding_test]' do
      fill_in 'coding_test[title]', with: '修正されたテストのコーディングテスト'
      click_button '更新する'
    end
    assert_selector '.page-content-header__title', text: '修正されたテストのコーディングテスト'
  end

  test 'delete a coding_test' do
    coding_test = coding_tests(:coding_test1)
    visit_with_auth "/mentor/coding_tests/#{coding_test.id}/edit", 'mentormentaro'
    accept_confirm do
      click_link '削除'
    end
    assert_no_text '最初の出力'
  end
end
