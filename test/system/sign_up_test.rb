# frozen_string_literal: true

require 'application_system_test_case'

class SignUpTest < ApplicationSystemTestCase
  test 'sign up' do
    WebMock.allow_net_connect!

    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      # 決め打ちメールアドレスにした場合テストを複数回実行すると失敗するため、ランダムでメールアドレスを生成する 詳細はissue#2035参照
      fill_in 'user[email]', with: "test-#{SecureRandom.hex(16)}@example.com"
      fill_in 'user[name]', with: 'テスト 太郎'
      fill_in 'user[name_kana]', with: 'テスト タロウ'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac', from: 'user[os]'
      select '未経験', from: 'user[experience]'
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 21', '111', '11122')

    click_button '利用規約に同意して参加する'
    sleep 1
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'

    WebMock.disable_net_connect!(
      allow_localhost: true,
      allow: 'chromedriver.storage.googleapis.com'
    )
  end

  test 'sign up with expired card' do
    WebMock.allow_net_connect!

    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: 'jiro@example.com'
      fill_in 'user[name]', with: 'テスト 次郎'
      fill_in 'user[name_kana]', with: 'テスト ジロウ'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac', from: 'user[os]'
      select '未経験', from: 'user[experience]'
    end

    fill_stripe_element('4000 0000 0000 0069', '12 / 21', '111', '11122')

    click_button '利用規約に同意して参加する'
    sleep 1
    assert_text 'クレジットカードが有効期限切れです。'

    WebMock.disable_net_connect!(
      allow_localhost: true,
      allow: 'chromedriver.storage.googleapis.com'
    )
  end

  test 'sign up with incorrect cvc card' do
    WebMock.allow_net_connect!

    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: 'saburo@example.com'
      fill_in 'user[name]', with: 'テスト 三郎'
      fill_in 'user[name_kana]', with: 'テスト サブロウ'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac', from: 'user[os]'
      select '未経験', from: 'user[experience]'
    end

    fill_stripe_element('4000 0000 0000 0127', '12 / 21', '111', '11122')

    click_button '利用規約に同意して参加する'
    sleep 1
    assert_text 'クレジットカードセキュリティコードが正しくありません。'

    WebMock.disable_net_connect!(
      allow_localhost: true,
      allow: 'chromedriver.storage.googleapis.com'
    )
  end

  test 'sign up with declined card' do
    WebMock.allow_net_connect!

    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: 'hanako@example.com'
      fill_in 'user[name]', with: 'テスト 花子'
      fill_in 'user[name_kana]', with: 'テスト ハナコ'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac', from: 'user[os]'
      select '未経験', from: 'user[experience]'
    end

    fill_stripe_element('4000 0000 0000 0002', '12 / 21', '111', '11122')

    click_button '利用規約に同意して参加する'
    sleep 1
    assert_text 'クレジットカードへの請求が拒否されました。'

    WebMock.disable_net_connect!(
      allow_localhost: true,
      allow: 'chromedriver.storage.googleapis.com'
    )
  end

  test 'sign up as adviser' do
    visit '/users/new?role=adviser'

    email = 'haruko@example.com'

    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト 春子'
      fill_in 'user[name_kana]', with: 'テスト ハルコ'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
    end
    click_button 'アドバイザー登録'
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert User.find_by(email: email).adviser?
  end

  test 'sign up as trainee' do
    visit '/users/new?role=trainee'

    email = 'natsumi@example.com'

    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト 夏美'
      fill_in 'user[name_kana]', with: 'テスト ナツミ'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac', from: 'user[os]'
      select '未経験', from: 'user[experience]'
    end
    click_button '利用規約に同意して参加する'
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert User.find_by(email: email).trainee?
  end

  test 'form item about job seek is only displayed to students' do
    visit '/users/new'
    assert has_field? 'user[job_seeker]', visible: :all
    visit '/users/new?role=adviser'
    assert has_no_field? 'user[job_seeker]', visible: :all
    visit '/users/new?role=trainee'
    assert has_no_field? 'user[job_seeker]', visible: :all
  end

  test 'sign up with reserved login name' do
    WebMock.allow_net_connect!

    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'mentor'
      fill_in 'user[email]', with: 'akiko@example.com'
      fill_in 'user[name]', with: 'テスト 秋子'
      fill_in 'user[name_kana]', with: 'テスト アキコ'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac', from: 'user[os]'
      select '未経験', from: 'user[experience]'
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 21', '111', '11122')

    click_button '利用規約に同意して参加する'
    assert_text 'に使用できない文字列が含まれています'

    WebMock.disable_net_connect!(
      allow_localhost: true,
      allow: 'chromedriver.storage.googleapis.com'
    )
  end

  test 'sign up as adviser with company_id' do
    visit "/users/new?role=adviser&company_id=#{companies(:company2).id}"

    email = 'fuyuko@example.com'

    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト ふゆこ'
      fill_in 'user[name_kana]', with: 'テスト フユコ'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
    end
    click_button 'アドバイザー登録'
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert_equal User.find_by(email: email).company_id, companies(:company2).id
  end
end
