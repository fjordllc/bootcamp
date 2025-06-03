# frozen_string_literal: true

require 'application_system_test_case'

class Home::ProfileSetupTest < ApplicationSystemTestCase
  test 'verify message presence of github_account registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'GitHubアカウントを登録してください。'

    users(:hajime).update!(github_account: 'hajime')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'GitHubアカウントを登録してください。'
  end

  test 'verify message presence of discord_profile_account_name registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'Discordアカウントを登録してください。'

    users(:hajime).discord_profile.update!(account_name: 'hajime1111')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'Discordアカウントを登録してください。'
  end

  test 'verify message presence of avatar registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'ユーザーアイコンを登録してください。'

    path = Rails.root.join('test/fixtures/files/users/avatars/default.jpg')
    users(:hajime).avatar.attach(io: File.open(path), filename: 'hajime.jpg')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'ユーザーアイコンを登録してください。'
  end

  test 'verify message presence of tags registration' do
    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'タグを登録してください。'

    users(:hatsuno).update!(tag_list: ['猫'])
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'タグを登録してください。'
  end

  test 'verify message presence of after_graduation_hope registration' do
    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'

    users(:hatsuno).update!(after_graduation_hope: 'ITジェンダーギャップ問題を解決するアプリケーションを作る事業に、プログラマーとして携わる。')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'
  end

  test 'verify message presence of blog_url registration' do
    users(:hatsuno).update!(blog_url: '') # 確認のために削除
    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'ブログURLを登録してください。'

    users(:hatsuno).update!(blog_url: 'http://hatsuno.org')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'ブログURLを登録してください。'
  end

  test 'visible announcement for activity time setup' do
    visit_with_auth '/', 'kimura'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert has_link?('活動時間を登録してください。', href: '/current_user/edit')
    click_on '活動時間を登録してください。'

    assert_selector 'h1.auth-form__title', text: '登録情報変更'
    assert_selector 'label.a-form-label', text: '主な活動予定時間'
    find('label[for="user_learning_time_frame_ids_1"]').click
    click_on '更新する'

    visit '/'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert has_no_link?('活動時間を登録してください。', href: '/current_user/edit')

    visit_with_auth '/', 'kensyu'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert has_link?('活動時間を登録してください。', href: '/current_user/edit')
    click_on '活動時間を登録してください。'

    assert_selector 'h1.auth-form__title', text: '登録情報変更'
    assert_selector 'label.a-form-label', text: '主な活動予定時間'
    find('label[for="user_learning_time_frame_ids_1"]').click
    click_on '更新する'

    visit '/'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert has_no_link?('活動時間を登録してください。', href: '/current_user/edit')
  end

  test 'not show message of after_graduation_hope for graduated user' do
    visit_with_auth '/', 'sotugyou'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'
  end

  test 'not show messages of required field' do
    user = users(:hatsuno)
    # hatsuno の未入力項目を登録
    user.build_discord_profile
    user.discord_profile.account_name = 'hatsuno1234'
    user.update!(
      tag_list: ['猫'],
      after_graduation_hope: 'ITジェンダーギャップ問題を解決するアプリケーションを作る事業に、プログラマーとして携わる。'
    )
    path = Rails.root.join('test/fixtures/files/users/avatars/hatsuno.jpg')
    user.avatar.attach(io: File.open(path), filename: 'hatsuno.jpg')
    LearningTimeFramesUser.create!(user:, learning_time_frame_id: 1)

    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text '未入力の項目'
  end
end
