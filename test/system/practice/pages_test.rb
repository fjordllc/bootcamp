# frozen_string_literal: true

require 'application_system_test_case'

class Practice::PagesTest < ApplicationSystemTestCase
  test 'show listing pages' do
    visit_with_auth "/practices/#{practices(:practice1).id}/pages", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールする | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show last updated user icon and role' do
    visit_with_auth "/practices/#{practices(:practice1).id}/pages", 'hajime'
    within '.thread-list-item-meta__icon-link' do
      assert_selector 'img[alt="komagata (Komagata Masaki): 管理者、メンター"]'
      assert_selector 'img[class="thread-list-item-meta__icon a-user-icon is-admin"]'
    end

    visit_with_auth "/practices/#{practices(:practice2).id}/pages", 'hajime'
    within '.thread-list-item-meta__icon-link' do
      assert_selector 'img[alt="kimura (Kimura Tadasi)"]'
      assert_selector 'img[class="thread-list-item-meta__icon a-user-icon is-student"]'
    end
  end
end
