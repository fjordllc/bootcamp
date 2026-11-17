# frozen_string_literal: true

require 'browserless_system_test_case'

module Products
  class ReviewScheduleBrowserlessTest < BrowserlessSystemTestCase
    test "don't show review schedule message on product page if mentor comments" do
      visit_with_auth "/products/#{products(:product10).id}", 'kimura'
      assert_no_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    end

    test "don't show review schedule message on product page if product is checked" do
      visit_with_auth "/products/#{products(:product2).id}", 'kimura'
      assert_no_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    end
  end
end
