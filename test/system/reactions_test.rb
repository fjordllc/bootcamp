# frozen_string_literal: true

require 'application_system_test_case'

class ReactionsTest < ApplicationSystemTestCase
  test 'post new reaction smile for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.report .js-reaction-dropdown-toggle').click
    first(".report .js-reaction-dropdown li[data-reaction-kind='smile']").click
    using_wait_time 5 do
      assert_text '😄2'
    end
  end

  test 'post all new reactions for report' do
    emojis = Reaction.emojis.filter { |key| key != 'smile' }
    visit_with_auth report_path(reports(:report1)), 'komagata'
    emojis.each do |key, value|
      first('.report .js-reaction-dropdown-toggle').click
      first(".report .js-reaction-dropdown li[data-reaction-kind='#{key}']").click
      using_wait_time 5 do
        assert_text "#{value}1"
      end
    end
  end

  test 'destroy reaction for report from dropdown' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.report .js-reaction-dropdown-toggle').click
    first(".report .js-reaction-dropdown li[data-reaction-kind='thumbsup']").click
    using_wait_time 5 do
      refute_text '👍1'
    end
  end

  test 'destroy reaction for report from footer' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.report .js-reaction li.is-reacted').click
    using_wait_time 5 do
      refute_text '👍1'
    end
  end

  test 'post new reaction for comment' do
    visit_with_auth report_path(reports(:report3)), 'komagata'
    first('.thread-comment .js-reaction-dropdown-toggle').click
    first(".thread-comment .js-reaction-dropdown li[data-reaction-kind='smile']").click
    using_wait_time 5 do
      assert_text '😄1'
    end
  end

  test 'destroy reaction for comment from dropdown' do
    visit_with_auth report_path(reports(:report3)), 'komagata'
    first('.thread-comment .js-reaction-dropdown-toggle').click
    first(".thread-comment .js-reaction-dropdown li[data-reaction-kind='heart']").click
    using_wait_time 5 do
      assert_text '❤️1'
    end
  end

  test 'destroy reaction for comment from footer' do
    visit_with_auth report_path(reports(:report3)), 'komagata'
    first(".thread-comment .js-reaction li[data-reaction-kind='heart']").click
    using_wait_time 5 do
      assert_text '❤️1'
    end
  end

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
