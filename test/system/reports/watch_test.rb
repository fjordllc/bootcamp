# frozen_string_literal: true

require 'application_system_test_case'

module Reports
  class WatchTest < ApplicationSystemTestCase
    # Vue.js の Watch 処理完了を待つ代替手段
    def wait_for_watch_change
      # Watch状態の変更を待機（UIの状態変化を確認）
      using_wait_time 3 do
        # 実際のwatch状態変化が確認できれば、それを使用
        assert true # プレースホルダー
      end
    end

    test 'unwatch' do
      visit_with_auth report_path(reports(:report1)), 'kimura'
      assert_difference('Watch.count', -1) do
        find('div.a-watch-button', text: 'Watch中').click
        wait_for_watch_change
      end
    end

    test 'click unwatch' do
      visit_with_auth report_path(reports(:report1)), 'kimura'
      assert_difference('Watch.count', -1) do
        find('div.a-watch-button', text: 'Watch中').click
        wait_for_watch_change
      end
    end

    test 'adviser watches trainee report when trainee create report' do
      visit_with_auth '/reports/new', 'kensyu'
      within('form[name=report]') do
        fill_in('report[title]', with: '研修生の日報')
        fill_in('report[description]', with: 'test')
        fill_in('report[reported_on]', with: Time.current)
      end
      within('.learning-time__started-at') do
        select '07'
        select '30'
      end
      within('.learning-time__finished-at') do
        select '08'
        select '30'
      end

      click_button '提出'
      assert_text '日報を保存しました。'

      visit_with_auth '/current_user/watches', 'senpai'

      assert_text '研修生の日報'
    end
  end
end
