# frozen_string_literal: true

require 'application_system_test_case'

module Products
  class TraineeTest < ApplicationSystemTestCase
    test "should add to trainer's watching list when trainee submits product" do
      users(:senpai).watches.delete_all

      visit_with_auth "/products/new?practice_id=#{practices(:practice3).id}", 'kensyu'
      within('form[name=product]') do
        fill_in('product[body]', with: '研修生が提出物を提出すると、その企業のアドバイザーのWatch中に登録される')
      end
      click_button '提出する'
      assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"

      visit_with_auth '/current_user/watches', 'senpai'
      assert_text '研修生が提出物を提出すると、その企業のアドバイザーのWatch中に登録される'
    end

    test 'no company trainee create product' do
      visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'nocompanykensyu'
      within('form[name=product]') do
        fill_in('product[body]', with: 'test')
      end
      click_button '提出する'
      assert_text Time.zone.now.strftime('%Y年%m月%d日')
      assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
      assert_text 'Watch中'
    end
  end
end
