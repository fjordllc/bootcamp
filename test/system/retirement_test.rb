# frozen_string_literal: true

require 'application_system_test_case'

class RetirementsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
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
end
