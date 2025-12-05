# frozen_string_literal: true

require 'application_system_test_case'

class HomeTest < ApplicationSystemTestCase
  test 'GET / without sign in' do
    logout
    visit '/'
    assert_equal 'プログラミングスクール FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /' do
    visit_with_auth '/', 'komagata'
    assert_equal 'ダッシュボード | FBC', title
  end

  test 'show latest announcements on dashboard' do
    visit_with_auth '/', 'hajime'
    assert_text '後から公開されたお知らせ'
    assert_no_text 'wipのお知らせ'
  end

  test 'show the grass for student' do
    assert users(:kimura).student?
    visit_with_auth '/', 'kimura'
    assert_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'show the grass for trainee' do
    assert users(:kensyu).trainee?
    visit_with_auth '/', 'kensyu'
    assert_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'not show the grass for mentor' do
    assert users(:mentormentaro).mentor?
    visit_with_auth '/', 'mentormentaro'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'not show the grass for adviser' do
    assert users(:advijirou).adviser?
    visit_with_auth '/', 'advijirou'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'not show the grass for admin' do
    assert users(:komagata).admin?
    visit_with_auth '/', 'komagata'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'show grass hide button for graduates' do
    visit_with_auth '/', 'kimura'
    assert_not has_button? '非表示'

    visit_with_auth '/', 'sotugyou'
    assert_selector 'h2.card-header__title', text: '学習時間'
    click_button '非表示'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'show and close welcome message' do
    visit_with_auth '/', 'advijirou'
    assert_text 'ようこそ'
    click_button '閉じる'
    visit '/'
    assert_no_text 'ようこそ'
  end

  test 'not show welcome message' do
    visit_with_auth '/', 'komagata'
    assert_no_text 'ようこそ'
  end

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

  test "show my wip's announcement on dashboard" do
    visit_with_auth '/', 'komagata'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-announcement' do
      assert_text 'お知らせ'
      find_link 'wipのお知らせ'
      assert_text I18n.l announcements(:announcement_wip).updated_at
    end
  end

  test "show my wip's page's date on dashboard" do
    visit_with_auth '/', 'komagata'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-page' do
      assert_text I18n.l pages(:page5).updated_at
    end
  end

  test "show my wip's report's date on dashboard" do
    visit_with_auth '/', 'sotugyou'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-report' do
      assert_text I18n.l reports(:report9).updated_at
    end
  end

  test "show my wip's question's date on dashboard" do
    Bookmark.destroy_all

    visit_with_auth '/', 'kimura'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-question' do
      assert_text I18n.l questions(:question_for_wip).updated_at
    end
  end

  test "show my wip's product's date on dashboard" do
    Bookmark.destroy_all

    visit_with_auth '/', 'kimura'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-product' do
      assert_text I18n.l products(:product5).updated_at
    end
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

  test 'show the latest reports for students' do
    visit_with_auth '/', 'hajime'
    assert_text '最新のみんなの日報'
  end

  test 'toggles_mentor_profile_visibility' do
    visit '/'
    assert_text '駒形 真幸'
    assert_text '株式会社ロッカの代表兼エンジニア。Rubyが大好きで怖話、フィヨルドブートキャンプなどを開発している。'
    visit_with_auth edit_current_user_path, 'komagata'
    uncheck 'プロフィール公開', allow_label_click: true
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'
    logout
    visit '/'
    assert_no_text '駒形 真幸'
    assert_no_text '株式会社ロッカの代表兼エンジニア。Rubyが大好きで怖話、フィヨルドブートキャンプなどを開発している。'
  end
end
