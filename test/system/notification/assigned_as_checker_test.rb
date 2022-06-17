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
    visit_with_auth "/products/#{products(:product1).id}/edit", 'komagata'
    select 'machida', from: 'product_checker_id'
    click_button '提出する'
    logout

    visit_with_auth '/notifications', 'machida'
    within first('.card-list-item.is-unread') do
      assert_text "mentormentaroさんの提出物「#{products(:product1).practice.title}」の提出物の担当になりました。"
    end

    last_mail = ActionMailer::Base.deliveries.last
    assert_equal "[bootcamp] mentormentaroさんの提出物#{products(:product1).title}の担当になりました。", last_mail.subject
  end

  test 'not notice self assigned as checker' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_link '内容修正'
    select 'komagata', from: 'product_checker_id'
    click_button '提出する'
    assert_text '担当から外れる'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_no_text "mentormentaroさんの提出物#{products(:product1).title}の担当になりました。"
  end
end
