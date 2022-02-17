# frozen_string_literal: true

require 'application_system_test_case'

class CampaignsTest < ApplicationSystemTestCase
  WEEK_DAY = %w[日 月 火 水 木 金 土].freeze

  test 'show link new campaign' do
    visit_with_auth admin_campaigns_path, 'komagata'
    assert_link 'お試し延長作成'
  end

  test 'not visit except admin' do
    visit_with_auth admin_campaigns_path, 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'create a new campaign' do
    today = Time.current
    seven_days_later = Time.current + 7.days
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse(today.to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse(seven_days_later.to_s)
      fill_in 'campaign[title]', with: 'お正月キャンペーン'
      click_button '内容を保存'
    end
    assert_text 'お試し延長を作成しました。'
    assert_text 'お正月キャンペーン'
    assert_text today.strftime("%Y年%m月%d日(#{WEEK_DAY[today.wday]}) %H:%M")
    assert_text seven_days_later.strftime("%Y年%m月%d日(#{WEEK_DAY[seven_days_later.wday]}) %H:%M")
  end

  test 'update a campaign' do
    visit_with_auth edit_admin_campaign_path(campaigns(:campaign1)), 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: '2022-03-01'
      fill_in 'campaign[end_at]', with: '2022-03-08'
      fill_in 'campaign[title]', with: '春のお試し祭り'
      click_button '内容を保存'
    end
    assert_text 'お試し延長を更新しました。'
    assert_text '春のお試し祭り'
  end

  test 'cannot create a new campaign when start_at > end_at' do
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[title]', with: 'お試し延長開始日時 > お試し延長終了日時のテスト'
      fill_in 'campaign[start_at]', with: Time.zone.parse('2021-12-10 00:00')
      fill_in 'campaign[end_at]', with: Time.zone.parse('2021-12-5 23:59')
      click_button '内容を保存'
    end
    assert_text '終了日時は開始日時よりも後の日時にしてください。'
  end

  test 'welcome trial extension campaign start to end' do
    start_at = Campaign.recently_campaign.first
    end_at = Campaign.recently_campaign.last

    campaign_start = start_at.strftime("%-m/%-d(#{WEEK_DAY[start_at.wday]})")
    campaign_end = end_at.strftime("%-m/%-d(#{WEEK_DAY[end_at.wday]})")

    visit welcome_path
    assert_text "#{campaign_start}〜#{campaign_end}の期間中にご入会いただくと、"
  end
end
