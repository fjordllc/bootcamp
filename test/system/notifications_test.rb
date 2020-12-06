# frozen_string_literal: true

require 'application_system_test_case'

class NotificationsTest < ApplicationSystemTestCase
  test 'do not send mail if user deny mail' do
    login_user 'kimura', 'testtest'
    visit "/reports/#{reports(:report8).id}"
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    wait_for_vuejs

    if ActionMailer::Base.deliveries.present?
      last_mail = ActionMailer::Base.deliveries.last
      assert_not_equal '[Bootcamp] kimuraさんからコメントが届きました。', last_mail.subject
    end
  end

  test "don't notify the same report" do
    login_user 'komagata', 'testtest'
    visit '/notifications'
    click_link '全て既読にする'

    login_user 'kensyu', 'testtest'
    visit '/reports/new'
    fill_in 'report_title', with: 'テスト日報'
    fill_in 'report_description', with: 'none'
    select '23', from: :report_learning_times_attributes_0_started_at_4i
    select '00', from: :report_learning_times_attributes_0_started_at_5i
    select '00', from: :report_learning_times_attributes_0_finished_at_4i
    select '00', from: :report_learning_times_attributes_0_finished_at_5i
    click_button '提出'

    find('#js-new-comment').set("login_nameの補完テスト: @komagata\n")
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'login_nameの補完テスト: @komagata'
    assert_selector :css, "a[href='/users/komagata']"

    login_user 'komagata', 'testtest'
    visit '/notifications'
    assert_no_text 'kensyuさんがはじめての日報を書きました！'
    assert_text 'kensyuさんからメンションがきました。'
  end
end
