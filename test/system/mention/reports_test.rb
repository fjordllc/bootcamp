# frozen_string_literal: true

require 'application_system_test_case'

module Mention
  class ReportsTest < ApplicationSystemTestCase
    setup do
      login_user 'kimura', 'testtest'
    end

    test 'mention from a report' do
      visit '/reports/new'
      fill_in 'report_title', with: 'テスト日報'
      fill_in 'report_description', with: '@hatsuno test'
      select '00', from: :report_learning_times_attributes_0_started_at_4i
      select '00', from: :report_learning_times_attributes_0_started_at_5i
      select '01', from: :report_learning_times_attributes_0_finished_at_4i
      select '00', from: :report_learning_times_attributes_0_finished_at_5i
      click_button '提出'

      login_user 'hatsuno', 'testtest'
      visit '/notifications'
      assert_text 'kimuraさんからメンションがきました。'
    end
  end
end
