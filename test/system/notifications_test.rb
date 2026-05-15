# frozen_string_literal: true

require 'application_system_test_case'

class NotificationsTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/introduction')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'do not send mail if user deny mail' do
    visit_with_auth "/reports/#{reports(:report8).id}", 'kimura'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    assert_selector '.thread-comment__description', text: 'test'

    denied_mail_subject = '[FBC] kimuraさんからコメントが届きました。'
    mail_subjects = ActionMailer::Base.deliveries.map(&:subject)
    assert_not_includes mail_subjects, denied_mail_subject
  end

  test "don't notify the same report" do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/reports/new', 'kimura'
    assert_text '日報作成'
    fill_in 'report_title', with: 'テスト日報'
    fill_in 'report_description', with: 'none'
    select '23', from: :report_learning_times_attributes_0_started_at_4i
    select '00', from: :report_learning_times_attributes_0_started_at_5i
    select '00', from: :report_learning_times_attributes_0_finished_at_4i
    select '00', from: :report_learning_times_attributes_0_finished_at_5i
    click_button '提出'
    assert_text '日報を保存しました。'

    perform_enqueued_jobs do
      find('#js-new-comment').set("login_nameの補完テスト: @komagata\n")
      click_button 'コメントする'
      assert_text 'login_nameの補完テスト: @komagata'
      assert_selector :css, "a[href='/users/komagata']"
    end

    visit_with_auth '/notifications', 'komagata'
    assert_no_text 'kimuraさんがはじめての日報を書きました！'
    assert_text 'kimuraさんからメンションがきました。'
  end

  test 'do not show read notification on the unread notifications' do
    Notification.create(message: '1番新しい既読の通知',
                        read: true,
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    visit_with_auth '/notifications?status=unread', 'mentormentaro'
    assert_no_text '1番新しい既読の通知'
  end

  test 'notify comment and check' do
    report_id = create_report_as('hatsuno', 'コメントと', '確認があった', save_as_wip: false)

    perform_enqueued_jobs do
      visit_with_auth "/reports/#{report_id}", 'komagata'
      assert_selector 'h1.page-content-header__title', text: 'コメントと'
      fill_in 'new_comment[description]', with: 'コメントと確認した'
      click_button '確認OKにする'
      logout
      visit_with_auth root_path, 'hatsuno'
      assert_selector 'h2.page-header__title', text: 'ダッシュボード'
      find('.header-links__link.test-show-notifications').click
      assert_text 'hatsunoさんの日報「コメントと」にkomagataさんがコメントしました。'
    end
  end

  test 'notify user class name role contains' do
    visit_with_auth '/', 'komagata'
    assert_text '6日以上経過'
    find('.header-links__link.test-show-notifications').click
    assert_selector 'span.a-user-role.is-admin'
    assert_selector 'span.a-user-role.is-student'
    assert_selector 'span.a-user-role.is-mentor'
  end
end
