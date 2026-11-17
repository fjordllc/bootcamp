# frozen_string_literal: true

require 'browserless_system_test_case'

class PairWorksBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing unsolved pair works' do
    visit_with_auth pair_works_path(target: 'not_solved'), 'kimura'
    assert_equal '募集中のペアワーク | FBC', title
  end

  test 'show listing solved pair works' do
    visit_with_auth pair_works_path(target: 'solved'), 'kimura'
    assert_equal 'ペア確定済みのペアワーク | FBC', title
  end

  test 'show listing all pair works' do
    visit_with_auth pair_works_path, 'kimura'
    assert_equal '全てのペアワーク | FBC', title
  end

  test 'cannot create a pair_work matching with a past date' do
    travel_to Time.zone.local(2025, 1, 10, 0, 0, 0) do
      pair_work = pair_works(:pair_work1)
      visit_with_auth pair_work_path(pair_work), 'komagata'
      assert_text '募集中'
      within '.a-table' do
        find_button(id: '2025-01-01T00:00:00+09:00', disabled: true)
      end
    end
  end

  test 'shows ended message when reserved date has passed' do
    travel_to Time.zone.local(2025, 1, 2, 1, 0, 0) do
      pair_work = pair_works(:pair_work4)
      visit_with_auth pair_work_path(pair_work), 'kimura'
      assert_selector "[for='show-ended-schedule']", text: 'ペアワークは終了しました。'

      visit_with_auth pair_work_path(pair_work), 'komagata'
      assert_selector "[for='show-ended-schedule']", text: 'ペアワークは終了しました。'
    end
  end
end
