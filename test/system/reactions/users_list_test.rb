# frozen_string_literal: true

require 'application_system_test_case'

module Reactions
  class UsersListTest < ApplicationSystemTestCase
    test 'does not show reaction users list when there are no reactions' do
      report = clear_reactions_from(reports(:report1))

      visit_with_auth report_path(report), 'komagata'
      within('.report.page-content') do
        assert_no_selector('.js-reactions-users-list', visible: :visible)
        find('.js-reactions-users-toggle').click
        assert_no_selector('.js-reactions-users-list', visible: :visible)
      end
    end

    test 'show reactions and links to user profile when clicking avatar' do
      machida = users(:machida)
      report = clear_reactions_from(reports(:report1))

      visit_with_auth report_path(report), 'machida'
      within('.report.page-content') do
        add_reaction('smile')
        assert_selector('.js-reactions-users-toggle:not(.is-disabled)')

        toggle_reaction_users_list
        within('.js-reactions-users-list') do
          assert_selector('span.reaction-emoji', text: '😄')
          click_link href: user_path(machida)
        end
      end
      assert_current_path user_path(machida)
    end

    test 'closes reaction users list when clicking toggle or outside but not inside' do
      report = clear_reactions_from(reports(:report1))

      visit_with_auth report_path(report), 'machida'
      within('.report.page-content') do
        add_reaction('smile')
        assert_selector('.js-reactions-users-toggle:not(.is-disabled)')

        toggle_reaction_users_list
        assert_selector('.js-reactions-users-list', visible: :visible)
        toggle_reaction_users_list
        assert_no_selector('.js-reactions-users-list', visible: :visible)

        toggle_reaction_users_list
        assert_selector('.js-reactions-users-list', visible: :visible)
        outside = find('.card-body')
        outside.click
        assert_no_selector('.js-reactions-users-list', visible: :visible)

        toggle_reaction_users_list
        assert_selector('.js-reactions-users-list', visible: :visible)
        inside = find('.js-reactions-users-list')
        inside.click
        assert_selector('.js-reactions-users-list', visible: :visible)
      end
    end

    test 'toggle has is-disabled when reactions not exist' do
      report = clear_reactions_from(reports(:report1))

      visit_with_auth report_path(report), 'machida'
      within('.report.page-content') do
        assert_selector('.reactions__dropdown-toggle.is-disabled')
        add_reaction('smile')
        assert_selector('.js-reactions-users-toggle:not(.is-disabled)')

        find("li[data-reaction-kind='smile'].is-reacted").click
        assert_selector('.js-reactions-users-toggle.is-disabled')
      end
    end
  end
end
