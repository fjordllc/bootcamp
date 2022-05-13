# frozen_string_literal: true

require 'application_system_test_case'

class Notification::AssignedAsCheckerTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'notify mentor when assigned as checker' do
    visit_with_auth "/products/#{products(:product11).id}/edit", 'komagata'
    select 'mentormentaro', from: 'product_checker_id'
    click_button '提出する'
    logout

    visit_with_auth '/notifications', 'mentormentaro'
    within first('.card-list-item.is-unread') do
      assert_text "hatsunoさんの提出物「#{products(:product11).practice.title}」の提出物の担当になりました。"
    end
  end
end
