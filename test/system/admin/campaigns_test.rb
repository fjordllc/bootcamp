# frozen_string_literal: true

require 'application_system_test_case'

class CampaignsTest < ApplicationSystemTestCase
  WEEK_DAY = %w[日 月 火 水 木 金 土].freeze
  TODAY = Time.current.beginning_of_day
  PERIOD = 6

  test 'non-admin cannot be visited campaign page' do
    visit_with_auth admin_campaigns_path, 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'admin can be visited campaign page' do
    visit_with_auth admin_campaigns_path, 'komagata'
    assert_link 'お試し延長作成'
  end

  test 'new campaign cannot be created' do
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse('2021-12-10 00:00')
      fill_in 'campaign[end_at]', with: Time.zone.parse('2021-12-15 23:58')
      fill_in 'campaign[title]', with: '終了日時の入力値がお試し日数に満たないケース'
      fill_in 'campaign[trial_period]', with: 6
      click_button '内容を保存'
    end
    assert_text '入力内容にエラーがありました'
    assert_text '終了日時は2021/12/15 23:59以降を入力してください。'
  end

  test 'new campaign can be created' do
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse('2021-12-10 00:00')
      fill_in 'campaign[end_at]', with: Time.zone.parse('2021-12-15 23:59')
      fill_in 'campaign[title]', with: '終了日時の入力値がお試し日数を満たすケース'
      fill_in 'campaign[trial_period]', with: 6
      click_button '内容を保存'
    end
    assert_text 'お試し延長を作成しました。'
    assert_text '終了日時の入力値がお試し日数を満たすケース'
    assert_text '6日'
    assert_text '2021年12月10日(金) 00:00'
    assert_text '2021年12月15日(水) 23:59'
  end

  # 開始日・終了日(datetime_field)のfill_inの年は６桁入るため頭を00で埋めている
  # 参照先：https://teratail.com/questions/301872
  test 'created campaign can be updated' do
    visit_with_auth edit_admin_campaign_path(campaigns(:campaign1)), 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: '002022-01-25-00-00'
      fill_in 'campaign[end_at]', with: '002022-01-29-23-59'
      fill_in 'campaign[title]', with: 'タイトル・お試し期間・開始日・終了日を更新'
      fill_in 'campaign[trial_period]', with: 5
      click_button '内容を保存'
    end
    assert_text 'お試し延長を更新しました。'
    assert_text 'タイトル・お試し期間・開始日・終了日を更新'
    assert_text '5日'
    assert_text '2022年01月25日(火) 00:00'
    assert_text '2022年01月29日(土) 23:59'
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
    assert_equal Campaign.today_campaign?, Campaign.recently_campaign.cover?(TODAY)

    visit welcome_path
    assert_no_text '通常 3日間 のお試し期間が'

    visit pricing_path
    example_start_at = TODAY.strftime('%-m月%-d日10時10分10秒')
    example_end_at = (TODAY + 3.days).strftime('%-m月%-d日10時10分9秒')
    example_pay_at = (TODAY + 3.days).strftime('%-m月%-d日10時10分10秒')

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

  test 'welcome 5days trial extension campaign period inside' do
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse(TODAY.to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse((TODAY + PERIOD.days).to_s)
      fill_in 'campaign[title]', with: 'お正月キャンペーン'
      fill_in 'campaign[trial_period]', with: 5
      click_button '内容を保存'
    end
    visit welcome_path
    assert_text 'お試し期間が延長！！'
  end

  test 'welcome trial extension campaign period inside' do
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse(TODAY.to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse((TODAY + PERIOD.days).to_s)
      fill_in 'campaign[title]', with: 'お試し延長キャンペーンの表示テスト'
      fill_in 'campaign[trial_period]', with: PERIOD
      click_button '内容を保存'
    end

    assert_equal Campaign.today_campaign?, Campaign.recently_campaign.cover?(TODAY)

    start_at = Campaign.recently_campaign.first
    end_at = Campaign.recently_campaign.last
    campaign_start = start_at.strftime("%-m/%-d(#{WEEK_DAY[start_at.wday]})")
    campaign_end = end_at.strftime("%-m/%-d(#{WEEK_DAY[end_at.wday]})")

    visit welcome_path
    assert_text 'お試し延長キャンペーンの表示テスト'
    assert_text 'お試し期間が倍以上に延長！！'
    assert_text "#{campaign_start}〜#{campaign_end}の期間中にご入会いただくと、"
    assert_text '通常 3日間 のお試し期間が'
    assert_text "#{PERIOD}日間 となります。"
    assert_text "#{PERIOD}日以内に退会すれば受講料はかかりません。"

    example_start_at = TODAY.strftime('%-m月%-d日10時10分10秒')
    example_end_at = (TODAY + PERIOD.days).strftime('%-m月%-d日10時10分9秒')
    example_pay_at = (TODAY + PERIOD.days).strftime('%-m月%-d日10時10分10秒')

    visit pricing_path
    assert_text "キャンペーン中につき、#{PERIOD}日間のお試し期間"
    assert_text "フィヨルドブートキャンプを使うべきかを判断するために#{PERIOD}日間のお試し期間を用意"
    assert_text "その#{PERIOD}日間、がっつりフィヨルドブートキャンプを見たり使ったりして判断してください。"

    assert_text "厳密にはお試し期間は#{PERIOD * 24}時間（#{PERIOD}日間）になります。"
    assert_text "例えば#{example_start_at}にフィヨルドブートキャンプを利用開始したとすると、"
    assert_text "そこから#{PERIOD}日後の#{example_end_at}がお試し期間終了のタイミングになります。"
    assert_text "その後#{example_pay_at}に最初の1ヶ月分の料金が引き落とされます。"

    assert_text "#{example_start_at} #{example_end_at} #{example_pay_at}"

    visit new_user_path
    assert_text 'お試し期間の延長が適用されます。'
    assert_text "クレジットカード登録日を含む#{PERIOD}日間はお試し期間です。"

    visit_with_auth '/', 'hatsuno'
    assert_text "入会から#{PERIOD}日間（#{PERIOD * 24}時間）は機能制限なくフルでフィヨルドブートキャンプを活用いただけます"
  end
end
