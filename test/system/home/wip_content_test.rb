# frozen_string_literal: true

require 'application_system_test_case'

class Home::WipContentTest < ApplicationSystemTestCase
  test "show my wip's page's date on dashboard" do
    visit_with_auth '/', 'komagata'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-page' do
      assert_text I18n.l pages(:page5).updated_at
    end
  end

  test "show my wip's report's date on dashboard" do
    visit_with_auth '/', 'sotugyou'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-report' do
      assert_text I18n.l reports(:report9).updated_at
    end
  end

  test "show my wip's question's date on dashboard" do
    Bookmark.destroy_all

    visit_with_auth '/', 'kimura'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-question' do
      assert_text I18n.l questions(:question_for_wip).updated_at
    end
  end

  test "show my wip's product's date on dashboard" do
    Bookmark.destroy_all

    visit_with_auth '/', 'kimura'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-product' do
      assert_text I18n.l products(:product5).updated_at
    end
  end
end
