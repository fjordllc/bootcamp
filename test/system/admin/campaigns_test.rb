# frozen_string_literal: true

require 'application_system_test_case'

class ExtendedTrialsTest < ApplicationSystemTestCase
  test 'show link new extended_trial' do
    visit_with_auth admin_extended_trials_path, 'komagata'
    assert_link 'お試し期間延長 作成'
  end

  test 'not visit except admin' do
    visit_with_auth admin_extended_trials_path, 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'create a new extended_trial' do
    today = Time.zone.today
    seven_days_later = Time.zone.today + 7.days
    wd = %w[日 月 火 水 木 金 土]
    visit_with_auth new_admin_extended_trial_path, 'komagata'
    within 'form[name=extended_trial]' do
      fill_in 'extended_trial[start_at]', with: Time.zone.parse(today.to_s)
      fill_in 'extended_trial[end_at]', with: Time.zone.parse(seven_days_later.to_s)
      fill_in 'extended_trial[title]', with: 'お正月キャンペーン'
      click_button '内容を保存'
    end
    assert_text 'お試し延長を作成しました。'
    assert_text 'お正月キャンペーン'
    assert_text today.strftime("%Y年%m月%d日(#{wd[today.wday]}) %H:%M")
    assert_text seven_days_later.strftime("%Y年%m月%d日(#{wd[seven_days_later.wday]}) %H:%M")
  end

  test 'update an extended_trial' do
    yesterday = Time.zone.today - 1.day
    five_days_later = Time.zone.today + 5.days
    wd = %w[日 月 火 水 木 金 土]
    visit_with_auth edit_admin_extended_trial_path(extended_trials(:extended_trial1)), 'komagata'
    within 'form[name=extended_trial]' do
      fill_in 'extended_trial[start_at]', with: Time.zone.parse(yesterday.to_s)
      fill_in 'extended_trial[end_at]', with: Time.zone.parse(five_days_later.to_s)
      fill_in 'extended_trial[title]', with: '春のお試し祭り'
      click_button '内容を保存'
    end
    assert_text 'お試し延長を更新しました。'
    assert_text '春のお試し祭り'
    assert_text (yesterday).strftime("%Y年%m月%d日(#{wd[yesterday.wday]}) %H:%M")
    assert_text (five_days_later).strftime("%Y年%m月%d日(#{wd[five_days_later.wday]}) %H:%M")
  end

  test 'cannot create a new extended_trial when start_at > end_at' do
    visit_with_auth new_admin_extended_trial_path, 'komagata'
    within 'form[name=extended_trial]' do
      fill_in 'extended_trial[title]', with: 'お試し延長開始日時 > お試し延長終了日時のテスト'
      fill_in 'extended_trial[start_at]', with: Time.zone.parse('2021-12-10 00:00')
      fill_in 'extended_trial[end_at]', with: Time.zone.parse('2021-12-5 23:59')
      click_button '内容を保存'
    end
    assert_text '終了日時は開始日時よりも後の日時にしてください。'
  end
end
