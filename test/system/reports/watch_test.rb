# frozen_string_literal: true

require 'application_system_test_case'

module Reports
  class WatchTest < ApplicationSystemTestCase
    # 画面上では更新の完了がわからないため、やむを得ずsleepする
    # 注意）安易に使用しないこと!! https://bootcamp.fjord.jp/pages/use-assert-text-instead-of-wait-for-vuejs
    def wait_for_watch_change
      sleep 1
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
