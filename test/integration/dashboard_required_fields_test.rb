# frozen_string_literal: true

require 'test_helper'

class DashboardRequiredFieldsTest < ActionDispatch::IntegrationTest
  AFTER_GRADUATION_HOPE_MESSAGE = 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'

  test 'shows message until github account is registered' do
    assert_message_disappears('hajime', 'GitHubアカウントを登録してください。') do |user|
      user.update!(github_account: 'hajime')
    end
  end

  test 'shows message until discord account is registered' do
    assert_message_disappears('hajime', 'Discordアカウントを登録してください。') do |user|
      user.discord_profile.update!(account_name: 'hajime1111')
    end
  end

  test 'shows message until avatar is registered' do
    assert_message_disappears('hajime', 'ユーザーアイコンを登録してください。') do |user|
      attach_avatar(user, 'users-avatars-default.jpg')
    end
  end

  test 'shows message until tags are registered' do
    assert_message_disappears('hatsuno', 'タグを登録してください。') do |user|
      user.update!(tag_list: ['猫'])
    end
  end

  test 'shows message until after graduation hope is registered' do
    assert_message_disappears('hatsuno', AFTER_GRADUATION_HOPE_MESSAGE) do |user|
      user.update!(after_graduation_hope: 'プログラマーとして働く。')
    end
  end

  test 'shows message until blog url is registered' do
    users(:hatsuno).update!(blog_url: '')
    assert_message_disappears('hatsuno', 'ブログURLを登録してください。') do |user|
      user.update!(blog_url: 'http://hatsuno.org')
    end
  end

  test 'shows link to register activity time until it is registered' do
    %w[kimura kensyu].each do |login_name|
      login(login_name)
      get root_path
      assert_select 'a[href="/current_user/edit"]', text: '活動時間を登録してください。'

      LearningTimeFramesUser.create!(user: users(login_name), learning_time_frame_id: 1)
      get root_path
      assert_select 'a[href="/current_user/edit"]', text: '活動時間を登録してください。', count: 0
    end
  end

  test 'does not show after graduation hope message to graduated user' do
    login('sotugyou')
    get root_path
    assert_select 'h2.page-header__title', text: 'ダッシュボード'
    assert_not_includes response.body, AFTER_GRADUATION_HOPE_MESSAGE
  end

  test 'does not show required field messages when all fields are registered' do
    user = users(:hatsuno)
    user.build_discord_profile
    user.discord_profile.account_name = 'hatsuno1234'
    user.update!(tag_list: ['猫'], after_graduation_hope: 'プログラマーとして働く。')
    attach_avatar(user, 'users-avatars-hatsuno.jpg')
    LearningTimeFramesUser.create!(user:, learning_time_frame_id: 1)

    login('hatsuno')
    get root_path
    assert_select 'h2.page-header__title', text: 'ダッシュボード'
    assert_not_includes response.body, '未入力の項目'
  end

  private

  def login(login_name)
    post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
  end

  def attach_avatar(user, filename)
    user.avatar.attach(io: Rails.root.join('test/fixtures/files', filename).open, filename:)
  end

  def assert_message_disappears(login_name, message)
    login(login_name)
    get root_path
    assert_select 'h2.page-header__title', text: 'ダッシュボード'
    assert_includes response.body, message

    yield users(login_name)
    get root_path
    assert_select 'h2.page-header__title', text: 'ダッシュボード'
    assert_not_includes response.body, message
  end
end
