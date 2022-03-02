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
      fill_in 'campaign[trial_period]', with: 7
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
      fill_in 'campaign[trial_period]', with: 7
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
      fill_in 'campaign[trial_period]', with: 7
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

  test 'welcome trial extension campaign period outside' do
    visit_with_auth edit_admin_campaign_path(campaigns(:campaign1)), 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: '2021-03-01'
      fill_in 'campaign[end_at]', with: '2021-03-08'
      fill_in 'campaign[title]', with: 'キャンペーン期間外でデフォルトのお試し期間3日間の表示テスト'
      fill_in 'campaign[trial_period]', with: 7
      click_button '内容を保存'
    end

    visit welcome_path
    assert_no_text '通常 3日間 のお試し期間が'

    today = Time.current
    example_start_at = today.strftime('%-m月%-d日10時10分10秒')
    example_end_at = (today + 3.days - 1).strftime('%-m月%-d日10時10分9秒')
    example_pay_at = (today + 3.days).strftime('%-m月%-d日10時10分10秒')

    visit pricing_path
    assert_text "3日間のお試し期間\n月額29,800円は決して安い金額ではありません。"
    assert_text 'フィヨルドブートキャンプを使うべきかを判断するために3日間のお試し期間を用意'
    assert_text 'その3日間、がっつりフィヨルドブートキャンプを見たり使ったりして判断してください。'

    assert_text '厳密にはお試し期間は72時間（3日間）になります。'
    assert_text "例えば#{example_start_at}にフィヨルドブートキャンプを利用開始したとすると、"
    assert_text "そこから3日後の#{example_end_at}がお試し期間終了のタイミングになります。"
    assert_text "その後#{example_pay_at}に最初の1ヶ月分の料金が引き落とされます。"

    assert_text "#{example_start_at} #{example_end_at} #{example_pay_at}"

    visit new_user_path
    assert_no_text 'お試し期間の延長が適用されます。'
    assert_text 'クレジットカード登録日を含む3日間はお試し期間です。'

    visit_with_auth '/', 'hatsuno'
    assert_text '入会から3日間（72時間）は機能制限なくフルでフィヨルドブートキャンプを活用いただけます'
  end

  test 'welcome trial extension campaign period inside' do
    today = Time.current
    trial_period = 7
    seven_days_later = Time.current + trial_period.days
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse(today.to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse(seven_days_later.to_s)
      fill_in 'campaign[title]', with: 'キャンペーン期間内のお試し延長期間7日間の表示テスト'
      fill_in 'campaign[trial_period]', with: trial_period
      click_button '内容を保存'
    end

    visit welcome_path
    assert_text '通常 3日間 のお試し期間が'
    assert_text "#{trial_period}日間 となります。"
    assert_text "#{trial_period}日以内に退会すれば受講料はかかりません。"

    example_start_at = today.strftime('%-m月%-d日10時10分10秒')
    example_end_at = (today + trial_period.days - 1).strftime('%-m月%-d日10時10分9秒')
    example_pay_at = (today + trial_period.days).strftime('%-m月%-d日10時10分10秒')

    visit pricing_path
    assert_text "キャンペーン中につき、#{trial_period}日間のお試し期間"
    assert_text "フィヨルドブートキャンプを使うべきかを判断するために#{trial_period}日間のお試し期間を用意"
    assert_text "その#{trial_period}日間、がっつりフィヨルドブートキャンプを見たり使ったりして判断してください。"

    assert_text "厳密にはお試し期間は#{trial_period * 24}時間（#{trial_period}日間）になります。"
    assert_text "例えば#{example_start_at}にフィヨルドブートキャンプを利用開始したとすると、"
    assert_text "そこから#{trial_period}日後の#{example_end_at}がお試し期間終了のタイミングになります。"
    assert_text "その後#{example_pay_at}に最初の1ヶ月分の料金が引き落とされます。"

    assert_text "#{example_start_at} #{example_end_at} #{example_pay_at}"

    visit new_user_path
    assert_text 'お試し期間の延長が適用されます。'
    assert_text "クレジットカード登録日を含む#{trial_period}日間はお試し期間です。"

    visit_with_auth '/', 'hatsuno'
    assert_text "入会から#{trial_period}日間（#{trial_period * 24}時間）は機能制限なくフルでフィヨルドブートキャンプを活用いただけます"
  end
end
