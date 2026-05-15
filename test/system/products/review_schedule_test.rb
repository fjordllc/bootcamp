# frozen_string_literal: true

require 'application_system_test_case'

module Products
  class ReviewScheduleTest < ApplicationSystemTestCase
    test 'show review schedule message on product page' do
      visit_with_auth "/products/#{products(:product8).id}", 'kimura'
      assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    end

    test "don't show review schedule message on product page if mentor comments" do
      visit_with_auth "/products/#{products(:product10).id}", 'kimura'
      assert_no_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    end

    test "don't show review schedule message on product page if product is checked" do
      visit_with_auth "/products/#{products(:product2).id}", 'kimura'
      assert_no_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    end

    test 'should change messages when submit product' do
      visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'hatsuno'
      within('form[name=product]') do
        fill_in('product[body]', with: 'test')
      end
      click_button '提出する'
      assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"

      visit "/practices/#{practices(:practice6).id}"
      assert_equal first('.test-product').text, '提出物へ'
    end
  end
end
