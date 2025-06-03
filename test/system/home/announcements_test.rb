# frozen_string_literal: true

require 'application_system_test_case'

class Home::AnnouncementsTest < ApplicationSystemTestCase
  test 'show latest announcements on dashboard' do
    visit_with_auth '/', 'hajime'
    assert_text '後から公開されたお知らせ'
    assert_no_text 'wipのお知らせ'
  end

  test "show my wip's announcement on dashboard" do
    visit_with_auth '/', 'komagata'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-announcement' do
      assert_text 'お知らせ'
      find_link 'wipのお知らせ'
      assert_text I18n.l announcements(:announcement_wip).updated_at
    end
  end

  test 'show the latest reports for students' do
    visit_with_auth '/', 'hajime'
    assert_text '最新のみんなの日報'
  end
end
