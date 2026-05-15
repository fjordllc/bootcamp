# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::SignedUpTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal

    @bot_token = Discord::Server.authorize_token
    Discord::Server.authorize_token = nil
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
    Discord::Server.authorize_token = @bot_token
  end

  test 'notify mentors when signed up as adviser' do
    visit '/users/new?role=adviser'

    email = 'haruko@example.com'

    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'haruko'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト 春子'
      fill_in 'user[name_kana]', with: 'テスト ハルコ'
      fill_in 'user[description]', with: 'テスト春子です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    click_button 'アドバイザー登録'
    assert_text 'アドバイザー登録が完了しました'
    assert User.find_by(email:).adviser?

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:signed_up], text: 'harukoさん(アドバイザー)が新しく入会しました！')
  end

  test 'notify mentors when signed up as mentor' do
    visit '/users/new?role=mentor'

    email = 'shunka@example.com'

    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'shunka'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト 春夏'
      fill_in 'user[name_kana]', with: 'テスト シュンカ'
      fill_in 'user[description]', with: 'テスト春夏です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      find('label', text: 'Mac（Intel チップ）').click
      first('.choices__inner').click
      find('.choices__list--dropdown').click
      find('.choices__list').click
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    click_button 'メンター登録'
    assert_text 'メンター登録が完了しました'
    assert User.find_by(email:).mentor?

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:signed_up], text: 'shunkaさん(メンター)が新しく入会しました！')
  end

  test 'notify mentors when signed up as trainee' do
    visit '/users/new?role=trainee_invoice_payment'

    email = 'natsumi@example.com'

    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'natsumi'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト 夏美'
      fill_in 'user[name_kana]', with: 'テスト ナツミ'
      fill_in 'user[description]', with: 'テスト夏美です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      find('label', text: 'Mac（Apple チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      first('.choices__inner').click
      find('.choices__list--dropdown').click
      find('.choices__list').click
      find('#choices--js-choices-single-select-item-choice-2').click
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    click_button '参加する'
    assert_text '研修生登録が完了しました'
    assert User.find_by(email:).trainee?

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:signed_up], text: 'natsumiさん(研修生)が新しく入会しました！')
  end

  test 'notify mentors when signed up as normal user' do
    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'taro'
      fill_in 'user[email]', with: 'test@example.com'
      fill_in 'user[name]', with: 'テスト 太郎'
      fill_in 'user[name_kana]', with: 'テスト タロウ'
      fill_in 'user[description]', with: 'テスト太郎です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      fill_in 'user[after_graduation_hope]', with: '起業したいです'
      select '学生', from: 'user[job]'
      find('label', text: 'Mac（Apple チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 50', '111')

    VCR.use_cassette 'sign_up/valid-card', vcr_options do
      click_button '参加する'
      assert_text '参加登録が完了しました'
    end

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:signed_up], text: 'taroさんが新しく入会しました！')
  end
end
