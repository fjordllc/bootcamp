# frozen_string_literal: true

require 'test_helper'

class UserProfileDisplayTest < ActionDispatch::IntegrationTest
  test 'shows graduation date only for graduated user' do
    login('komagata')
    get user_path(users(:mentormentaro))
    assert_includes response.body, 'mentormentaro'
    assert_not_includes response.body, '卒業日'

    get user_path(users(:sotugyou))
    assert_includes response.body, '卒業日'
  end

  test 'shows retired date and retire reason to admin only for retired user' do
    login('komagata')
    get user_path(users(:yameo))
    assert_includes response.body, '退会日'
    assert_includes response.body, '退会理由'

    get user_path(users(:sotugyou))
    assert_includes response.body, 'sotugyou'
    assert_not_includes response.body, '退会日'
    assert_not_includes response.body, '退会理由'
  end

  test 'shows completed practices' do
    login('machida')
    get user_path(users(:kimura))
    assert_includes response.body, 'OS X Mountain Lionをクリーンインストールする'
    assert_not_includes response.body, 'Terminalの基礎を覚える'
  end

  # 見られる人 => 休会履歴の見出し
  { kyuukai: '現在1回目の休会中', hukki: '1回目の休会' }.each do |target, title|
    %w[komagata mentormentaro].each do |login_name|
      test "shows hibernation history of #{target} to #{login_name}" do
        login(login_name)
        get user_path(users(target))
        assert_select '.card-header__title', text: '休会履歴（1回）'
        assert_select '.user-metas__title', text: title
      end
    end
  end

  test 'shows hibernation period only for hibernated user' do
    hibernated_user = users(:kyuukai)
    travel_to hibernated_user.hibernated_at + 30.days do
      login('komagata')
      get user_path(hibernated_user)
      assert_includes response.body, '（休会から30日目）'
    end

    login('komagata')
    get user_path(users(:hatsuno))
    assert_response :success
    assert_not_includes response.body, '（休会から'
  end

  test 'does not show button to hide grass for graduates' do
    login('sotugyou')
    get user_path(users(:sotugyou))
    assert_includes response.body, 'sotugyou'
    assert_select 'button', text: '非表示', count: 0
  end

  private

  def login(login_name)
    post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
  end
end
