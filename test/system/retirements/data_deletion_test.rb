# frozen_string_literal: true

require 'application_system_test_case'

module Retirements
  class DataDeletionTest < ApplicationSystemTestCase
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

    test 'cancel participation in regular event upon retirement' do
      regular_event = regular_events(:regular_event1)
      visit_with_auth regular_event_path(regular_event), 'kimura'
      accept_confirm do
        click_link '参加申込'
      end
      assert_text '参加登録しました。'

      visit_with_auth new_retirement_path, 'kimura'
      find('label', text: 'とても良い').click
      click_on '退会する'
      page.driver.browser.switch_to.alert.accept
      assert_text '退会処理が完了しました'

      visit_with_auth "regular_events/#{regular_event.id}", 'komagata'
      within('.a-card.participants') do
        assert_no_selector '.is-kimura'
      end
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
      user.github_account = 'github_kimura'
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

    test 'do not show warning for finished regular events' do
      regular_event = regular_events(:regular_event39)

      visit_with_auth new_retirement_path, regular_event.user.login_name
      assert_no_text 'ご自身が主催者である定期イベントがあります。'
    end
  end
end
