# frozen_string_literal: true

require 'application_system_test_case'

module Pages
  class UserChangeTest < ApplicationSystemTestCase
    test 'administrator can change doc user' do
      visit_with_auth "/pages/#{pages(:page1).id}/edit", 'komagata'

      within('.form') do
        find('#select2-page_user_id-container').click
        select('kimura', from: 'page[user_id]')
        find('.select-users').click
      end

      click_button '内容を更新'
      within '.a-meta.is-creator' do
        assert find('.thread-header__user-icon')[:title].start_with?('kimura')
      end
      within '.a-meta.is-updater' do
        assert_equal 'komagata', find('.a-user-name').text
      end
    end

    test 'non-administrator cannot change doc user' do
      visit_with_auth "/pages/#{pages(:page1).id}/edit", 'kimura'
      assert_no_selector '.select-users'

      visit '/pages/new'
      assert_no_selector '.select-users'
      within('.form') do
        fill_in('page[title]', with: 'Created by non-admin')
        fill_in('page[body]', with: "非管理者によって作られたDocです。It's created by non-admin.")
      end
      click_on 'Docを公開'

      click_on '内容変更'
      assert_no_selector '.select-users'
    end
  end
end
