# frozen_string_literal: true

require 'application_system_test_case'

class NotificationsTest < ApplicationSystemTestCase
  test 'do not send mail if user deny mail' do
    visit_with_auth "/reports/#{reports(:report8).id}", 'kimura'
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

    find('#js-new-comment').set("login_nameの補完テスト: @komagata\n")
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'login_nameの補完テスト: @komagata'
    assert_selector :css, "a[href='/users/komagata']"

    visit_with_auth '/notifications', 'komagata'
    wait_for_vuejs
    assert_no_text 'kensyuさんがはじめての日報を書きました！'
    assert_text 'kensyuさんからメンションがきました。'
  end

  test 'do not show read notification on the unread notifications' do
    Notification.create(message: '1番新しい既読の通知',
                        read: true,
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:yamada),
                        sender: users(:machida))
    visit_with_auth '/notifications?status=unread', 'yamada'
    wait_for_vuejs
    assert_no_text '1番新しい既読の通知'
  end

  test 'click on the pager button' do
    # 1ページに表示する通知の数は20件なのでtimesメソッドを使って19件作成し、一番新しい通知、古い通知を個別に作成する
    19.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:yamada),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:yamada),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:yamada),
                        sender: users(:machida))
    visit_with_auth '/notifications', 'yamada'
    wait_for_vuejs
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
                          user: users(:yamada),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:yamada),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:yamada),
                        sender: users(:machida))
    login_user 'yamada', 'testtest'
    visit '/notifications?page=2'
    wait_for_vuejs
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
                          user: users(:yamada),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:yamada),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:yamada),
                        sender: users(:machida))
    login_user 'yamada', 'testtest'
    visit '/notifications?page=2'
    wait_for_vuejs
    within first('nav.pagination') do
      find('a', text: '1').click
    end
    page.go_back
    wait_for_vuejs
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  test 'notify comment and check' do
    login_user 'hatsuno', 'testtest'
    report = create_report 'コメントと', '確認があった', false

    visit_with_auth "/reports/#{report}", 'komagata'
    visit "/reports/#{report}"
    fill_in 'new_comment[description]', with: 'コメントと確認した'
    click_button '確認OKにする'

    visit_with_auth "/reports/#{report}", 'hatsuno'
    find('.header-links__link.test-show-notifications').click
    wait_for_vuejs
    assert_text 'hatsunoさんの【 「コメントと」の日報 】にkomagataさんがコメントしました。'
  end

  test 'show notification count' do
    Notification.create(message: 'machidaさんからメンションが届きました',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:yamada),
                        sender: users(:machida))

    visit_with_auth '/notifications', 'yamada'
    wait_for_vuejs
    assert_selector '.header-notification-count', text: '1'

    20.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:yamada),
                          sender: users(:machida))
    end
    visit_with_auth '/notifications', 'yamada'
    wait_for_vuejs
    assert_selector '.header-notification-count', text: '21'
  end

  test 'show listing unread notification' do
    visit_with_auth '/notifications?status=unread', 'hatsuno'
    assert_equal '通知 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'non-mentor can not see a button to open all unread notifications' do
    Notification.create(message: 'machidaさんがコメントしました',
                        kind: 'came_comment',
                        link: '/reports/20400118',
                        user: users(:hatsuno),
                        sender: users(:machida))
    visit_with_auth '/notifications?status=unread', 'hatsuno'
    wait_for_vuejs
    assert_no_button '未読の通知を一括で開く'
  end

  test 'mentor can see a button to open to open all unread notifications' do
    Notification.create(message: 'machidaさんがコメントしました',
                        kind: 'came_comment',
                        link: '/reports/20400118',
                        user: users(:komagata),
                        sender: users(:machida))
    visit_with_auth '/notifications?status=unread', 'komagata'
    wait_for_vuejs
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
    wait_for_vuejs
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
    wait_for_vuejs
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
    wait_for_vuejs
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
    wait_for_vuejs
    click_link 'お知らせの通知を既読にする'

    visit_with_auth '/notifications?status=unread&target=announcement', 'komagata'
    wait_for_vuejs
    assert_no_text 'お知らせのテスト通知'

    visit_with_auth '/notifications?status=unread&target=comment', 'komagata'
    wait_for_vuejs
    assert_text 'コメントのテスト通知'

    visit_with_auth '/notifications?status=unread', 'komagata'
    wait_for_vuejs
    assert_text 'コメントのテスト通知'
  end

  test 'notice another mentor assigned as checker' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_link '内容修正'
    select 'machida', from: 'product_checker_id'
    click_button '提出する'
    assert_text 'machida'

    visit_with_auth '/notifications?status=unread', 'machida'
    wait_for_vuejs
    assert_text "yamadaさんの提出物#{products(:product1).title}の担当になりました。"

    if ActionMailer::Base.deliveries.present?
      last_mail = ActionMailer::Base.deliveries.last
      assert_equal "[bootcamp] yamadaさんの提出物#{products(:product1).title}の担当になりました。", last_mail.subject
    end
  end

  test 'not notice self assigned as checker' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_link '内容修正'
    select 'komagata', from: 'product_checker_id'
    click_button '提出する'
    assert_text '担当から外れる'

    visit_with_auth '/notifications?status=unread', 'komagata'
    wait_for_vuejs
    assert_no_text "yamadaさんの提出物#{products(:product1).title}の担当になりました。"
  end
end
