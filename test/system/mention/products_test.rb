# frozen_string_literal: true

require "application_system_test_case"

module Mention
  class ProductsTest < ApplicationSystemTestCase
    setup do
      login_user "kimura", "testtest"
    end

    test "mention from a report" do
      practice = practices(:practice_5)
      visit "/products/new?practice_id=#{practice.id}"
      within("#new_product") do
        fill_in("product[body]", with: "@machida test")
      end
      click_button "提出する"
      assert_text "提出物を作成しました。7日以内にメンターがレビューしますので、次のプラクティスにお進みください。"

      login_user "machida", "testtest"
      visit "/notifications"
      assert_text "kimuraさんからメンションがきました。"
    end
  end
end
