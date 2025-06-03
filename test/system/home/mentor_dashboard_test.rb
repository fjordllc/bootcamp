# frozen_string_literal: true

require 'application_system_test_case'

class Home::MentorDashboardTest < ApplicationSystemTestCase
  test 'mentor can products that are more than 4 days.' do
    visit_with_auth '/', 'mentormentaro'
    assert_text '6日以上経過（7）'
    assert_text '5日経過（1）'
    assert_text '4日経過（1）'
  end

  test 'display counts of passed almost 5days' do
    visit_with_auth '/', 'mentormentaro'
    assert_text "2件の提出物が、\n8時間以内に4日経過に到達します。"

    products(:product70).update!(checker: users(:mentormentaro))
    visit current_path
    assert_text "1件の提出物が、\n8時間以内に4日経過に到達します。"

    products(:product71).update!(checker: users(:mentormentaro))
    visit current_path
    assert_text "しばらく4日経過に到達する\n提出物はありません。"
  end

  test 'work link of passed almost 5days' do
    visit_with_auth '/', 'mentormentaro'
    find('.under-cards').click
    assert_current_path('/products/unassigned')
  end

  test 'display message if no product after 5 days' do
    Product.delete_all
    user = users(:kimura)
    practice = practices(:practice1)
    Product.create(practice_id: practice.id, user_id: user.id, body: 'test body', published_at: Time.current.ago(1.day))
    travel_to Time.current do
      visit_with_auth '/', 'komagata'
      assert_text 'しばらく4日経過に到達する'
      assert_text '提出物はありません。'
    end
  end
end
