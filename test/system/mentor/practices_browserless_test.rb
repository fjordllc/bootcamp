# frozen_string_literal: true

require 'browserless_system_test_case'

class Mentor::PracticesBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing practices' do
    visit_with_auth mentor_practices_path, 'mentormentaro'
    assert_equal 'プラクティス | FBC', title
  end

  test 'show practice page' do
    visit_with_auth mentor_practices_path, 'mentormentaro'
    within first('.admin-table__item') do
      assert_text 'sshdでパスワード認証を禁止にする'
    end
  end

  test 'adviser cannot delete practice' do
    practice = practices(:practice7)
    visit_with_auth "/practices/#{practice.id}", 'advijirou'

    assert_text practice.title
    assert_no_link '削除する'
  end

  test 'student cannot delete practice' do
    practice = practices(:practice7)

    Capybara.using_driver(:rack_test) do
      visit_with_auth "/practices/#{practice.id}", 'kimura'
      assert_text practice.title
      assert_no_link '削除する'
    end
  end
end
