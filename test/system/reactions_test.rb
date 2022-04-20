# frozen_string_literal: true

require 'application_system_test_case'

class ReactionsTest < ApplicationSystemTestCase
  test 'post new reaction smile for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.card-body .js-reaction-dropdown-toggle').click
    first(".card-body .js-reaction-dropdown li[data-reaction-kind='smile']").click
    using_wait_time 5 do
      assert_text '😄2'
    end
  end

  test 'destroy reaction for report from dropdown' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.card-body .js-reaction-dropdown-toggle').click
    first(".card-body .js-reaction-dropdown li[data-reaction-kind='thumbsup']").click
    using_wait_time 5 do
      refute_text '👍1'
    end
  end

  test 'destroy reaction for report from footer' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.card-body .js-reaction li.is-reacted').click
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

  test 'post new reaction thumbsup for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='thumbsup']").click
    using_wait_time 5 do
      assert_text '👍1'
    end
  end

  test 'post new reaction tada for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='tada']").click
    using_wait_time 5 do
      assert_text '🎉1'
    end
  end

  test 'post new reaction heart for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='heart']").click
    using_wait_time 5 do
      assert_text '❤️1'
    end
  end

  test 'post new reaction rocket for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='rocket']").click
    using_wait_time 5 do
      assert_text '🚀1'
    end
  end

  test 'post new reaction eyes for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='eyes']").click
    using_wait_time 5 do
      assert_text '👀1'
    end
  end

  test 'post new reaction hundred for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='hundred']").click
    using_wait_time 5 do
      assert_text '💯1'
    end
  end

  test 'post new reaction flexed for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='flexed']").click
    using_wait_time 5 do
      assert_text '💪1'
    end
  end

  test 'post new reaction okwoman for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='okwoman']").click
    using_wait_time 5 do
      assert_text '🙆‍♀️1'
    end
  end

  test 'post new reaction loudlycrying for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='loudlycrying']").click
    using_wait_time 5 do
      assert_text '😭1'
    end
  end

  test 'post new reaction raised_hands for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='raised_hands']").click
    using_wait_time 5 do
      assert_text '🙌1'
    end
  end

  test 'post new reaction pray for report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    first('.thread__body .js-reaction-dropdown-toggle').click
    first(".thread__body .js-reaction-dropdown li[data-reaction-kind='pray']").click
    using_wait_time 5 do
      assert_text '🙏1'
    end
  end
end
