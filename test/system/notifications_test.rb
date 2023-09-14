# frozen_string_literal: true

require 'application_system_test_case'

class NotificationsTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
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

    if ActionMailer::Base.deliveries.present?
      last_mail = ActionMailer::Base.deliveries.last
      assert_not_equal '[FBC] kimuraさんからコメントが届きました。', last_mail.subject
    end
  end

  test "don't notify the same report" do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/reports/new', 'kensyu'
    fill_in 'report_title', with: 'テスト日報'
    fill_in 'report_description', with: 'none'
    select '23', from: :report_learning_times_attributes_0_started_at_4i
    select '00', from: :report_learning_times_attributes_0_started_at_5i
    select '00', from: :report_learning_times_attributes_0_finished_at_4i
    select '00', from: :report_learning_times_attributes_0_finished_at_5i
    click_button '提出'

    perform_enqueued_jobs do
      find('#js-new-comment').set("login_nameの補完テスト: @komagata\n")
      click_button 'コメントする'
      assert_text 'login_nameの補完テスト: @komagata'
      assert_selector :css, "a[href='/users/komagata']"
    end

    visit_with_auth '/notifications', 'komagata'
    assert_no_text 'kensyuさんがはじめての日報を書きました！'
    assert_text 'kensyuさんからメンションがきました。'
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

  test 'click on the pager button' do
    # 1ページに表示する通知の数は20件なのでtimesメソッドを使って19件作成し、一番新しい通知、古い通知を個別に作成する
    19.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:mentormentaro),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    visit_with_auth '/notifications', 'mentormentaro'
    within first('nav.pagination') do
      find('a', text: '2').click
    end
    # 2ページ目に1番古い通知が表示されることを確認
    assert_text '1番古い通知'
    # 2ページ目に1番新しい通知が表示されないことを確認
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/notifications?page=2')
  end

  test 'specify the page number in the URL' do
    19.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:mentormentaro),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    login_user 'mentormentaro', 'testtest'
    visit '/notifications?page=2'
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  test 'clicking the browser back button will show the previous page' do
    19.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:mentormentaro),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    login_user 'mentormentaro', 'testtest'
    visit '/notifications?page=2'
    within first('nav.pagination') do
      find('a', text: '1').click
    end
    page.go_back
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  test 'notify comment and check' do
    login_user 'hatsuno', 'testtest'
    report = create_report 'コメントと', '確認があった', false

    perform_enqueued_jobs do
      visit_with_auth "/reports/#{report}", 'komagata'
      visit "/reports/#{report}"
      fill_in 'new_comment[description]', with: 'コメントと確認した'
      click_button '確認OKにする'
      visit_with_auth "/reports/#{report}", 'hatsuno'
      find('.header-links__link.test-show-notifications').click
      assert_text 'hatsunoさんの【 「コメントと」の日報 】にkomagataさんがコメントしました。'
    end
  end

  test 'notify user class name role contains' do
    visit_with_auth '/', 'komagata'
    find('.header-links__link.test-show-notifications').click
    assert_selector 'span.a-user-role.is-admin'
    assert_selector 'span.a-user-role.is-student'
    assert_selector 'span.a-user-role.is-mentor'
  end

  test 'show notification count' do
    Notification.create(message: 'machidaさんからメンションが届きました',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:kananashi),
                        sender: users(:machida))

    visit_with_auth '/notifications', 'kananashi'
    assert_selector '.header-notification-count', text: '1'

    20.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:kananashi),
                          sender: users(:machida))
    end
    visit_with_auth '/notifications', 'kananashi'
    assert_selector '.header-notification-count', text: '21'
  end

  test 'show listing unread notification' do
    visit_with_auth '/notifications?status=unread', 'hatsuno'
    assert_equal '通知 | FBC', title
  end

  test 'non-mentor can not see a button to open all unread notifications' do
    Notification.create(message: 'machidaさんがコメントしました',
                        kind: 'came_comment',
                        link: '/reports/20400118',
                        user: users(:hatsuno),
                        sender: users(:machida))
    visit_with_auth '/notifications?status=unread', 'hatsuno'
    assert_no_button '未読の通知を一括で開く'
  end

  test 'mentor can see a button to open to open all unread notifications' do
    Notification.create(message: 'machidaさんがコメントしました',
                        kind: 'came_comment',
                        link: '/reports/20400118',
                        user: users(:komagata),
                        sender: users(:machida))
    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_button '未読の通知を一括で開く'
  end

  test 'show listing notification that target is all' do
    Notification.create(message: 'お知らせの通知',
                        kind: 'announced',
                        link: '/announcements/1',
                        user: users(:komagata),
                        sender: users(:machida))
    Notification.create(message: 'コメントの通知',
                        kind: 'came_comment',
                        link: '/reports/1',
                        user: users(:komagata),
                        sender: users(:machida))
    visit_with_auth '/notifications', 'komagata'
    assert_text 'コメントの通知'
    assert_text 'お知らせの通知'
  end

  test 'show listing notification that target is announcements' do
    Notification.create(message: 'お知らせの通知',
                        kind: 'announced',
                        link: '/announcements/1',
                        user: users(:komagata),
                        sender: users(:machida))
    Notification.create(message: 'コメントの通知',
                        kind: 'came_comment',
                        link: '/reports/1',
                        user: users(:komagata),
                        sender: users(:machida))
    visit_with_auth '/notifications?target=announcement', 'komagata'
    assert_text 'お知らせの通知'
    assert_no_text 'コメントの通知'
  end

  test 'show listing unread notification that target is announcements' do
    Notification.create(message: '未読のお知らせの通知',
                        kind: 'announced',
                        link: '/announcements/1',
                        user: users(:komagata),
                        sender: users(:machida))
    Notification.create(message: '既読のお知らせの通知',
                        kind: 'announced',
                        link: '/announcements/2',
                        user: users(:komagata),
                        sender: users(:machida),
                        read: true)
    visit_with_auth '/notifications?status=unread&target=announcement', 'komagata'
    assert_text '未読のお知らせの通知'
    assert_no_text '既読のお知らせの通知'
  end

  test 'click on the category marks button' do
    Notification.create(message: 'お知らせのテスト通知',
                        kind: 'announced',
                        link: '/announcements/1',
                        user: users(:komagata),
                        sender: users(:machida))
    Notification.create(message: 'コメントのテスト通知',
                        kind: 'came_comment',
                        link: '/reports/1',
                        user: users(:komagata),
                        sender: users(:machida))
    visit_with_auth '/notifications?status=unread&target=announcement', 'komagata'
    click_link 'お知らせを既読にする'

    visit_with_auth '/notifications?status=unread&target=announcement', 'komagata'
    assert_no_text 'お知らせのテスト通知'

    visit_with_auth '/notifications?status=unread&target=comment', 'komagata'
    assert_text 'コメントのテスト通知'

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_text 'コメントのテスト通知'
  end

  test 'show the number of unread mentions on the badge of the mentioned tab' do
    user = users(:kimura)
    expected_number_of_unread_mentions = user.notifications.by_target(:mention).unreads.latest_of_each_link.size

    visit_with_auth '/notifications', user.login_name

    within '.page-tabs__item', text: 'メンション' do
      actual_number_of_unread_mentions = find('.a-notification-count').text.to_i

      assert_equal expected_number_of_unread_mentions, actual_number_of_unread_mentions
    end
  end

  test 'don\'t show the badge on the mentioned tab if no unread mentions' do
    user = users(:kimura)
    user.notifications.by_target(:mention).where(read: false).update_all(read: true) # rubocop:disable Rails/SkipsModelValidations

    visit_with_auth '/notifications', user.login_name

    within '.page-tabs__item', text: 'メンション' do
      assert_no_selector '.a-notification-count'
    end
  end
end
