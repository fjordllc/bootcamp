# frozen_string_literal: true

require 'application_system_test_case'

class Events::AnnouncementTest < ApplicationSystemTestCase
  test 'when the create announcements checkbox is enabled, the user is redirected to the new announcement page after create a new event' do
    event = {
      title: 'チェックボックスを有効にするとお知らせ作成ページにリダイレクトする',
      description: 'お知らせ作成ページには、リダイレクト元のイベント情報が自動入力される'
    }

    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: event[:title]
      fill_in 'event[description]', with: event[:description]
      fill_in 'event[capacity]', with: 10
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      check 'イベント公開のお知らせを書く', allow_label_click: true
      click_button 'イベントを公開'
    end

    assert_text 'イベントを作成しました'
    within 'form[name=announcement]' do
      assert has_field? 'announcement[title]', with: /#{event[:title]}/
      assert has_field? 'announcement[description]', with: /#{event[:description]}/
    end
  end

  test 'when the create announcements checkbox is enabled, the user is redirected to the new announcement page after edit a wip event' do
    event = {
      title: 'WIP中のイベントを公開する際、チェックボックスを有効にするとお知らせ作成ページにリダイレクトする',
      description: 'お知らせ作成ページには、リダイレクト元のイベント情報が自動入力される'
    }

    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: event[:title]
      fill_in 'event[description]', with: event[:description]
      fill_in 'event[capacity]', with: 10
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      check 'イベント公開のお知らせを書く', allow_label_click: true
      click_button 'WIP'
    end

    check 'イベント公開のお知らせを書く', allow_label_click: true
    click_button '内容を更新'

    assert_text 'イベントを更新しました'
    within 'form[name=announcement]' do
      assert has_field? 'announcement[title]', with: /#{event[:title]}/
      assert has_field? 'announcement[description]', with: /#{event[:description]}/
    end
  end

  test 'checkboxes for creating an announcement are display the new event page' do
    visit_with_auth new_event_path, 'komagata'
    assert_selector 'label', text: 'イベント公開のお知らせを書く'
  end

  test 'checkboxes for creating an announcement are display the edit page of wip event' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: 'WIPで保存したイベントの編集画面にはチェックボックスを表示'
      fill_in 'event[description]', with: '説明文'
      fill_in 'event[capacity]', with: 10
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button 'WIP'
    end

    assert_selector 'label', text: 'イベント公開のお知らせを書く'
  end

  test 'checkboxes for creating an announcement are not display the edit page of published event' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '公開したイベントの編集画面にはチェックボックスを表示しない'
      fill_in 'event[description]', with: '説明文'
      fill_in 'event[capacity]', with: 10
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button 'イベントを公開'
    end
    click_link '内容修正'
    assert_no_selector 'label', text: 'イベント公開のお知らせを書く'
  end
end
