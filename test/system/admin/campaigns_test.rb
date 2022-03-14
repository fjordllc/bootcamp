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

  test 'created campaign can be updated' do
    visit_with_auth edit_admin_campaign_path(campaigns(:campaign1)), 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[title]', with: '(タイトルを更新)'
      fill_in 'campaign[trial_period]', with: 5
      click_button '内容を保存'
    end
    assert_text 'お試し延長を更新しました。'
    assert_text '(タイトルを更新)'
  end

  test 'trial extension campaign period outside' do
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
    assert_no_text 'キャンペーン適用'
    assert_no_text 'お試し期間延長が適用され'
    assert_text 'クレジットカード登録日を含む3日間はお試し期間です。'
  end

  test '5days trial extension campaign period inside' do
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse(TODAY.to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse((TODAY + PERIOD.days).to_s)
      fill_in 'campaign[title]', with: 'お試し期間が倍でない延長キャンペーン！'
      fill_in 'campaign[trial_period]', with: 5
      click_button '内容を保存'
    end
    visit welcome_path
    assert_text 'お試し期間が倍でない延長キャンペーン！'
    assert_text 'お試し期間が延長！！'
  end

  test '6days trial extension campaign period inside' do
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse(TODAY.to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse((TODAY + PERIOD.days).to_s)
      fill_in 'campaign[title]', with: 'お試し期間が倍以上の延長キャンペーン！！！'
      fill_in 'campaign[trial_period]', with: PERIOD
      click_button '内容を保存'
    end

    assert_equal Campaign.today_campaign?, Campaign.recently_campaign.cover?(TODAY)

    start_at = Campaign.recently_campaign.first
    end_at = Campaign.recently_campaign.last
    campaign_start = start_at.strftime("%-m/%-d(#{WEEK_DAY[start_at.wday]})")
    campaign_end = end_at.strftime("%-m/%-d(#{WEEK_DAY[end_at.wday]})")

    visit welcome_path
    assert_text 'お試し期間が倍以上の延長キャンペーン！！！'
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
    assert_text '（現在、キャンペーン中のためお試し期間を延長しています）'
    assert_text "その#{PERIOD}日間、がっつりフィヨルドブートキャンプを見たり使ったりして判断してください。"

    assert_text "厳密にはお試し期間は#{PERIOD * 24}時間（#{PERIOD}日間）になります。"
    assert_text "例えば#{example_start_at}にフィヨルドブートキャンプを利用開始したとすると、"
    assert_text "そこから#{PERIOD}日後の#{example_end_at}がお試し期間終了のタイミングになります。"
    assert_text "その後#{example_pay_at}に最初の1ヶ月分の料金が引き落とされます。"

    assert_text "#{example_start_at} #{example_end_at} #{example_pay_at}"

    visit new_user_path
    assert_text 'キャンペーン適用'
    assert_text 'お試し期間が倍以上の延長キャンペーン！！！ のお試し期間延長が適用され、'
    assert_text "通常 3日間 のお試し期間が #{PERIOD}日間 になります。"
    assert_text "クレジットカード登録日を含む#{PERIOD}日間はお試し期間です。"
  end

  test 'when user joined campaign period just before/after the start' do
    current_time = Time.current
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse(current_time.to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse((current_time + 10.days).to_s)
      fill_in 'campaign[title]', with: 'キャンペーン期間の開始直前/後に入会したとき'
      fill_in 'campaign[trial_period]', with: 7
      click_button '内容を保存'
    end

    assert_nil Campaign.target_user?(join_date: current_time - 1.minute)
    assert Campaign.target_user?(join_date: current_time, current_time: current_time + 7.days - 1.minute)
    assert_not Campaign.target_user?(join_date: current_time, current_time: current_time + 7.days)
  end

  test 'when user joined campaign period just before/after the end' do
    current_time = Time.current
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse((current_time - 10.days).to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse((current_time + 1.minute).to_s)
      fill_in 'campaign[title]', with: 'キャンペーン期間の終了直前/後に入会したとき'
      fill_in 'campaign[trial_period]', with: 7
      click_button '内容を保存'
    end

    assert Campaign.target_user?(join_date: current_time, current_time: current_time + 7.days - 1.minute)
    assert_not Campaign.target_user?(join_date: current_time, current_time: current_time + 7.days)
    assert_nil Campaign.target_user?(join_date: current_time + 1.minute)
  end

  test 'welcome page when user joined campaign period outside' do
    visit_with_auth '/', 'hatsuno'
    assert_text '入会から3日間（72時間）は機能制限なくフルでフィヨルドブートキャンプを活用いただけます'
  end

  test 'welcome page when user joined campaign period inside' do
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse((TODAY - 2.years).to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse((TODAY + 2.years).to_s)
      fill_in 'campaign[title]', with: 'お試し期間が倍でない延長キャンペーン！'
      fill_in 'campaign[trial_period]', with: 777
      click_button '内容を保存'
    end

    visit_with_auth '/', 'hatsuno'
    assert_text 'お試し期間延長のキャンペーンが適用されているので、'
    assert_text "入会から777日間（#{777 * 24}時間）は機能制限なくフルでフィヨルドブートキャンプを活用いただけます"
  end
end
