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
    # Exclude smile and thumbsup as they already exist on report1
    emojis = Reaction.emojis.filter { |key| !%w[smile thumbsup].include?(key) }
    visit_with_auth report_path(reports(:report1)), 'komagata'
    emojis.each do |key, value|
      using_wait_time 15 do
        # Wait for dropdown toggle to be clickable
        assert_selector '.report .js-reaction-dropdown-toggle', visible: true
        first('.report .js-reaction-dropdown-toggle').click
        # Wait for dropdown menu to be displayed
        assert_selector ".report .js-reaction-dropdown li[data-reaction-kind='#{key}']", visible: true
        first(".report .js-reaction-dropdown li[data-reaction-kind='#{key}']").click
        # Wait for reaction to be displayed
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
end
