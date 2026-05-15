# frozen_string_literal: true

require 'application_system_test_case'

module Talks
  class ContentTest < ApplicationSystemTestCase
    test 'both public and private information is displayed' do
      user = users(:kimura)
      visit_with_auth "/talks/#{user.talk.id}", 'kimura'
      assert_no_text 'ユーザー非公開情報'
      assert_no_text 'ユーザー公開情報'

      logout
      visit_with_auth "/talks/#{user.talk.id}", 'komagata'
      assert_text 'ユーザー非公開情報'
      assert_text 'ユーザー公開情報'
    end

    test 'update memo' do
      user = users(:kimura)
      visit_with_auth "/talks/#{user.talk.id}", 'komagata'
      assert_text 'kimuraさんのメモ'
      click_button '編集'
      fill_in 'js-user-mentor-memo', with: '相談部屋テストメモ'
      click_button '保存する'
      assert_text '相談部屋テストメモ'
      assert_no_text 'kimuraさんのメモ'
    end

    test 'Displays a list of the 10 most recent reports' do
      user = users(:hajime)
      visit_with_auth "/talks/#{user.talk.id}", 'komagata'
      assert_text 'ユーザーの日報'
      page.find('#side-tabs-nav-2').click
      user.reports.first(10).each do |report|
        assert_text report.title
      end
    end

    test 'hide user icon from recent reports in talk show' do
      user = users(:hajime)
      visit_with_auth "/talks/#{user.talk.id}", 'komagata'
      page.find('#side-tabs-nav-2').click
      assert_no_selector('.card-list-item__user')
    end

    test 'talk show without recent reports' do
      user = users(:muryou)
      visit_with_auth "/talks/#{user.talk.id}", 'komagata'
      page.find('#side-tabs-nav-2').click
      assert_text '日報はまだありません。'
    end

    test 'display company-logo in consultation room when user is trainee' do
      visit_with_auth "/talks/#{talks(:talk11).id}", 'kensyu'
      assert_selector 'img[class="page-content-header__company-logo-image"]'
    end
  end
end
