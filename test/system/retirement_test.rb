# frozen_string_literal: true

require 'application_system_test_case'

class RetirementTest < ApplicationSystemTestCase
  test 'retire user' do
    user = users(:kananashi)
    visit_with_auth new_retirement_path, 'kananashi'
    choose '良い', visible: false
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'
    assert_equal Date.current, user.reload.retired_on
    assert_equal 'kananashiさんが退会しました。', users(:komagata).notifications.last.message
    assert_equal 'kananashiさんが退会しました。', users(:machida).notifications.last.message

    login_user 'kananashi', 'testtest'
    assert_text 'ログインができません'

    user = users(:osnashi)
    visit_with_auth new_retirement_path, 'osnashi'
    choose '良い', visible: false
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'
    assert_equal Date.current, user.reload.retired_on
    assert_equal 'osnashiさんが退会しました。', users(:komagata).notifications.last.message
    assert_equal 'osnashiさんが退会しました。', users(:machida).notifications.last.message

    login_user 'osnashi', 'testtest'
    assert_text 'ログインができません'
  end

  test 'delete unchecked products when the user retired' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice5).id}", 'muryou'
    within('#new_product') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text "提出物を提出しました。7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\n7日以上待ってもレビューされない場合は、気軽にメンターにメンションを送ってください。"
    visit edit_current_user_path
    click_on '退会手続き'
    check '受講したいカリキュラムを全て受講したから', allow_label_click: true
    fill_in 'user[retire_reason]', with: '辞' * 8
    choose '良い', visible: false
    fill_in 'user[opinion]', with: 'ご意見'
    assert_difference 'Product.unchecked.count', -1 do
      page.accept_confirm '本当によろしいですか？' do
        click_on '退会する'
      end
      assert_text '退会処理が完了しました'
    end
  end

  test 'delete WIP reports when the user retired' do
    visit_with_auth '/reports/new', 'muryou'
    within('#new_report') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
    end
    click_button 'WIP'
    assert_text '日報をWIPとして保存しました。'
    visit edit_current_user_path
    click_on '退会手続き'
    check '受講したいカリキュラムを全て受講したから', allow_label_click: true
    fill_in 'user[retire_reason]', with: '辞' * 8
    choose '良い', visible: false
    fill_in 'user[opinion]', with: 'ご意見'
    assert_difference 'Report.wip.count', -1 do
      page.accept_confirm '本当によろしいですか？' do
        click_on '退会する'
      end
      assert_text '退会処理が完了しました'
    end
  end

  test '退会理由がすべて表示されているか' do
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

  test 'メンター以外に退会理由が表示されていないか' do
    visit_with_auth "/users/#{users(:yameo).id}", 'hatsuno'
    assert_no_text '退会理由'
    assert_no_text '受講したいカリキュラムを全て受講したから'
    assert_no_text '学ぶ必要がなくなったから'
    assert_no_text '他のスクールに通うことにしたから'
    assert_no_text '学習時間を取ることが難しくなったから'
    assert_no_text '学ぶ意欲が落ちたから'
  end

  test '退会していないユーザーに退会理由が表示されていないか' do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'komagata'
    assert_no_text '退会理由'
    assert_no_text '受講したいカリキュラムを全て受講したから'
    assert_no_text '学ぶ必要がなくなったから'
    assert_no_text '他のスクールに通うことにしたから'
    assert_no_text '学習時間を取ることが難しくなったから'
    assert_no_text '学ぶ意欲が落ちたから'
  end
end
