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

    if ActionMailer::Base.deliveries.present?
      last_mail = ActionMailer::Base.deliveries.last
      assert_not_equal '[FBC] kimuraさんからコメントが届きました。', last_mail.subject
    end
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
    login_user 'mentormentaro', 'testtest'
    visit '/notifications'
    within first('nav.pagination') do
      click_link_or_button '2'
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

  test 'show 20 notifications in first page' do
    25.times do |n|
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
    login_user 'mentormentaro', 'testtest'
    visit '/notifications'
    assert_text '1番新しい通知'
    assert_equal 20, all('.card-list-item').size

    visit '/notifications?status=unread'
    assert_text '1番新しい通知'
    assert_equal 20, all('.card-list-item').size
  end

  test 'click on the pager button with query string' do
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
    visit '/notifications?status=unread'
    within first('nav.pagination') do
      click_link_or_button '2'
    end
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_match %r{/notifications\?(status=unread&page=2|page=2&status=unread)}, current_url
  end

  test 'click on the pager button with multiple query string' do
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
    visit '/notifications?status=unread&target=mention'
    within first('nav.pagination') do
      click_link_or_button '2'
    end
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_match %r{/notifications\?(status=unread&target=mention&page=2|page=2&status=unread&target=mention)}, current_url
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
      click_link_or_button '1'
    end
    assert_text '1番新しい通知'
    page.go_back
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
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
