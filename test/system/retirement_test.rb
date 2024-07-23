# frozen_string_literal: true

require 'application_system_test_case'

class RetirementTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'retire user' do
    user = users(:kananashi)
    visit_with_auth new_retirement_path, 'kananashi'
    find('label', text: 'とても良い').click
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'
    assert_equal Date.current, user.reload.retired_on
    assert_equal '😢 kananashiさんが退会しました。', users(:komagata).notifications.last.message
    assert_equal '😢 kananashiさんが退会しました。', users(:mentormentaro).notifications.last.message

    login_user 'kananashi', 'testtest'
    assert_text '退会したユーザーです'

    user = users(:osnashi)
    visit_with_auth new_retirement_path, 'osnashi'
    find('label', text: 'とても良い').click
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'
    assert_equal Date.current, user.reload.retired_on
    assert_equal '😢 osnashiさんが退会しました。', users(:komagata).notifications.last.message
    assert_equal '😢 osnashiさんが退会しました。', users(:mentormentaro).notifications.last.message

    login_user 'osnashi', 'testtest'
    assert_text '退会したユーザーです'
  end

  test 'retire user with times_channel' do
    user = users(:hajime)
    user.discord_profile.times_id = '987654321987654321'
    user.discord_profile.account_name = 'hatsuno#1234'
    user.save!(validate: false)

    Discord::Server.stub(:delete_text_channel, true) do
      visit_with_auth new_retirement_path, user.login_name
      find('label', text: 'とても良い').click
      click_on '退会する'
      page.driver.browser.switch_to.alert.accept
      assert_text '退会処理が完了しました'
    end
    assert_equal Date.current, user.reload.retired_on
    assert_nil user.discord_profile.times_id
    assert_nil user.discord_profile.times_url
  end

  test 'retire user with postmark error' do
    logs = []
    stub_warn_logger = ->(message) { logs << message }
    Rails.logger.stub(:warn, stub_warn_logger) do
      stub_postmark_error = ->(_user) { raise Postmark::InactiveRecipientError }
      UserMailer.stub(:retire, stub_postmark_error) do
        user = users(:kananashi)
        visit_with_auth new_retirement_path, 'kananashi'
        find('label', text: 'とても良い').click
        click_on '退会する'
        page.driver.browser.switch_to.alert.accept
        assert_text '退会処理が完了しました'
        assert_equal Date.current, user.reload.retired_on
      end
    end

    assert_match '[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：', logs.to_s
  end

  test 'enables retirement regardless of validity of discord id' do
    user = users(:discordinvalid)
    visit_with_auth new_retirement_path, 'discordinvalid'
    find('label', text: 'とても悪い').click
    click_on '退会する'
    page.accept_confirm
    assert_text '退会処理が完了しました'
    assert_equal Date.current, user.reload.retired_on
    assert_equal '😢 discordinvalidさんが退会しました。', users(:komagata).notifications.last.message
    assert_equal '😢 discordinvalidさんが退会しました。', users(:mentormentaro).notifications.last.message

    login_user 'discordinvalid', 'testtest'
    assert_text '退会したユーザーです'
  end

  test 'enables retirement regardless of validity of X（Twitter） ID' do
    user = users(:twitterinvalid)
    visit_with_auth new_retirement_path, 'twitterinvalid'
    find('label', text: 'とても悪い').click
    click_on '退会する'
    page.accept_confirm
    assert_text '退会処理が完了しました'
    assert_equal Date.current, user.reload.retired_on
    assert_equal '😢 twitterinvalidさんが退会しました。', users(:komagata).notifications.last.message
    assert_equal '😢 twitterinvalidさんが退会しました。', users(:mentormentaro).notifications.last.message

    login_user 'twitterinvalid', 'testtest'
    assert_text '退会したユーザーです'
  end

  test 'delete unchecked products when the user retired' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice5).id}", 'muryou'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    visit edit_current_user_path
    click_on '退会手続き'
    check '受講したいカリキュラムを全て受講したから', allow_label_click: true
    fill_in 'user[retire_reason]', with: '辞' * 8
    find('label', text: 'とても良い').click
    fill_in 'user[opinion]', with: 'ご意見'
    assert_difference 'Product.unchecked.count', -2 do
      page.accept_confirm '本当によろしいですか？' do
        click_on '退会する'
      end
      assert_text '退会処理が完了しました'
    end
  end

  test 'delete WIP reports when the user retired' do
    visit_with_auth '/reports/new', 'muryou'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
    end
    click_button 'WIP'
    assert_text '日報をWIPとして保存しました。'
    visit edit_current_user_path
    click_on '退会手続き'
    check '受講したいカリキュラムを全て受講したから', allow_label_click: true
    fill_in 'user[retire_reason]', with: '辞' * 8
    find('label', text: 'とても良い').click
    fill_in 'user[opinion]', with: 'ご意見'
    assert_difference 'Report.wip.count', -1 do
      page.accept_confirm '本当によろしいですか？' do
        click_on '退会する'
      end
      assert_text '退会処理が完了しました'
    end
  end

  test 'show all reasons for retirement' do
    visit_with_auth new_retirement_path, 'kananashi'
    assert_text '受講したいカリキュラムを全て受講したから'
    assert_text '学ぶ必要がなくなったから'
    assert_text '他のスクールに通うことにしたから'
    assert_text '学習時間を取ることが難しくなったから'
    assert_text '学ぶ意欲が落ちたから'
    assert_text 'カリキュラムに満足できなかったから'
    assert_text 'スタッフのサポートに満足できなかったから'
    assert_text '学ぶ環境に満足できなかったから'
    assert_text '受講料が高いから'
    assert_text '転職や引っ越しなど環境の変化によって学びが継続できなくなったから'
    assert_text '企業研修で利用をしていて研修期間が終了したため'
  end

  test 'show reasons for retirement only to mentor' do
    visit_with_auth "/users/#{users(:yameo).id}", 'hatsuno'
    assert_no_text '退会理由'
    assert_no_text '受講したいカリキュラムを全て受講したから'
    assert_no_text '学ぶ必要がなくなったから'
    assert_no_text '他のスクールに通うことにしたから'
    assert_no_text '学習時間を取ることが難しくなったから'
    assert_no_text '学ぶ意欲が落ちたから'
  end

  test 'show reasons for retirement only retirement users' do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'komagata'
    assert_no_text '退会理由'
    assert_no_text '受講したいカリキュラムを全て受講したから'
    assert_no_text '学ぶ必要がなくなったから'
    assert_no_text '他のスクールに通うことにしたから'
    assert_no_text '学習時間を取ることが難しくなったから'
    assert_no_text '学ぶ意欲が落ちたから'
  end

  test 'GET /retirement' do
    visit '/retirement'
    assert_equal 'FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'retire with event organizer' do
    visit_with_auth new_retirement_path, 'hajime'
    find('label', text: 'とても良い').click
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'

    regular_event = regular_events(:regular_event4)
    visit_with_auth "regular_events/#{regular_event.id}", 'kimura'
    assert_no_selector '.is-hajime'

    visit_with_auth new_retirement_path, 'kimura'
    find('label', text: 'とても良い').click
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'

    visit_with_auth "regular_events/#{regular_event.id}", 'komagata'
    assert_no_selector '.is-kimura'
    assert_selector '.is-komagata'
  end

  test 'should clear github data on account deletion' do
    user = users(:kimura)
    user.github_id = '12345'
    user.github_account = 'kimura'
    user.github_collaborator = true
    user.save!(validate: false)
    visit_with_auth new_retirement_path, 'kimura'
    find('label', text: 'とても良い').click
    page.accept_confirm '本当によろしいですか？' do
      click_on '退会する'
    end
    assert_text '退会処理が完了しました'
    user.reload
    assert_nil user.github_id
    assert_nil user.github_account
    assert_not user.github_collaborator
  end
end
