# frozen_string_literal: true

require 'application_system_test_case'

class Notification::SignedUpTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
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
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert User.find_by(email: email).adviser?

    visit_with_auth notifications_path, 'komagata'
    within first('.card-list-item.is-unread') do
      assert_selector '.card-list-item-title__link-label', text: '🎉 harukoさんが新しく入会しました！'
    end
  end

  test 'notify mentors when signed up as trainee' do
    visit '/users/new?role=trainee'

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
      select '未経験', from: 'user[experience]'
      first('.choices__inner').click
      find('.choices__list--dropdown').click
      find('.choices__list').click
      find('#choices--js-choices-single-select-item-choice-2').click
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    click_button '参加する'
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert User.find_by(email: email).trainee?

    visit_with_auth notifications_path, 'komagata'
    within first('.card-list-item.is-unread') do
      assert_selector '.card-list-item-title__link-label', text: '🎉 natsumiさんが新しく入会しました！'
    end
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
      select '未経験', from: 'user[experience]'
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 50', '111')

    VCR.use_cassette 'sign_up/valid-card', vcr_options do
      click_button '参加する'
      assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    end

    visit_with_auth notifications_path, 'komagata'
    within first('.card-list-item.is-unread') do
      assert_selector '.card-list-item-title__link-label', text: '🎉 taroさんが新しく入会しました！'
    end
  end
end
