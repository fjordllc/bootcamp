# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::PracticesTest < ApplicationSystemTestCase
  test 'show listing practices' do
    visit_with_auth mentor_practices_path, 'mentormentaro'
    assert_equal 'プラクティス | FBC', title
  end

  test 'show practice page' do
    visit_with_auth mentor_practices_path, 'mentormentaro'
    first('.admin-table__item').assert_text 'sshdでパスワード認証を禁止にする'
  end

  test 'admin can delete practice' do
    practice = practices(:practice7)
    visit_with_auth "/practices/#{practice.id}", 'komagata'

    assert_text practice.title

    accept_confirm do
      click_link '削除する'
    end

    assert_text 'プラクティスを削除しました。'
    assert_current_path mentor_practices_path

    assert_no_text practice.title
  end

  test 'mentor can delete practice' do
    practice = practices(:practice7)
    visit_with_auth "/practices/#{practice.id}", 'mentormentaro'

    assert_text practice.title

    accept_confirm do
      click_link '削除する'
    end

    assert_text 'プラクティスを削除しました。'
    assert_current_path mentor_practices_path

    assert_no_text practice.title
  end

  test 'adviser cannot delete practice' do
    practice = practices(:practice7)
    visit_with_auth "/practices/#{practice.id}", 'advijirou'

    assert_text practice.title
    assert_no_link '削除する'
  end

  test 'student cannot delete practice' do
    practice = practices(:practice7)
    visit_with_auth "/practices/#{practice.id}", 'kimura'

    assert_text practice.title
    assert_no_link '削除する'
  end
end
