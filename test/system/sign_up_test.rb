# frozen_string_literal: true

require 'application_system_test_case'

class SignUpTest < ApplicationSystemTestCase
  VCR_OPTIONS = {
    record: :once,
    match_requests_on: [
      :method,
      VCR.request_matchers.uri_without_param(:source)
    ]
  }.freeze

  test 'sign up' do
    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: 'test@example.com'
      fill_in 'user[name]', with: 'テスト 太郎'
      fill_in 'user[name_kana]', with: 'テスト タロウ'
      fill_in 'user[description]', with: 'テスト太郎です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac(Intel)', from: 'user[os]'
      select '未経験', from: 'user[experience]'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 21', '111')

    VCR.use_cassette 'sign_up/valid-card', record: :once, match_requests_on: %i[method uri] do
      click_button '参加する'
      assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    end
  end

  test 'sign up with expired card' do
    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: 'jiro@example.com'
      fill_in 'user[name]', with: 'テスト 次郎'
      fill_in 'user[name_kana]', with: 'テスト ジロウ'
      fill_in 'user[description]', with: 'テスト次郎です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac(Intel)', from: 'user[os]'
      select '未経験', from: 'user[experience]'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
    end

    fill_stripe_element('4000 0000 0000 0069', '12 / 21', '111')

    VCR.use_cassette 'sign_up/expired-card', VCR_OPTIONS do
      click_button '参加する'
      assert_text 'クレジットカードが有効期限切れです。'
    end
  end

  test 'sign up with incorrect cvc card' do
    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: 'saburo@example.com'
      fill_in 'user[name]', with: 'テスト 三郎'
      fill_in 'user[name_kana]', with: 'テスト サブロウ'
      fill_in 'user[description]', with: 'テスト三郎です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac(Intel)', from: 'user[os]'
      select '未経験', from: 'user[experience]'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
    end

    fill_stripe_element('4000 0000 0000 0127', '12 / 21', '111')

    VCR.use_cassette 'sign_up/incorrect-cvc-card', VCR_OPTIONS do
      click_button '参加する'
      assert_text 'クレジットカードセキュリティコードが正しくありません。'
    end
  end

  test 'sign up with declined card' do
    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: 'hanako@example.com'
      fill_in 'user[name]', with: 'テスト 花子'
      fill_in 'user[name_kana]', with: 'テスト ハナコ'
      fill_in 'user[description]', with: 'テスト花子です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac(Intel)', from: 'user[os]'
      select '未経験', from: 'user[experience]'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
    end

    fill_stripe_element('4000 0000 0000 0002', '12 / 21', '111')

    VCR.use_cassette 'sign_up/declined-card', VCR_OPTIONS do
      click_button '参加する'
      assert_text 'クレジットカードへの請求が拒否されました。'
    end
  end

  test 'sign up as adviser' do
    visit '/users/new?role=adviser'

    email = 'haruko@example.com'

    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト 春子'
      fill_in 'user[name_kana]', with: 'テスト ハルコ'
      fill_in 'user[description]', with: 'テスト春子です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
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
      fill_in 'user[description]', with: 'テスト夏美です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac(Intel)', from: 'user[os]'
      select '未経験', from: 'user[experience]'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
    end

    click_button '参加する'
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
    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'mentor'
      fill_in 'user[email]', with: 'akiko@example.com'
      fill_in 'user[name]', with: 'テスト 秋子'
      fill_in 'user[name_kana]', with: 'テスト アキコ'
      fill_in 'user[description]', with: 'テスト秋子です。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac(Intel)', from: 'user[os]'
      select '未経験', from: 'user[experience]'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 21', '111')

    VCR.use_cassette 'sign_up/valid-card' do
      click_button '参加する'
      assert_text 'に使用できない文字列が含まれています'
    end
  end

  test 'sign up as adviser with company_id' do
    visit "/users/new?role=adviser&company_id=#{companies(:company2).id}"

    email = 'fuyuko@example.com'

    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト ふゆこ'
      fill_in 'user[name_kana]', with: 'テスト フユコ'
      fill_in 'user[description]', with: 'テストふゆこです。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
    end

    click_button 'アドバイザー登録'
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert_equal User.find_by(email: email).company_id, companies(:company2).id
  end

  test 'sign up as trainee with course_id' do
    course = courses(:course2)
    visit "/users/new?role=trainee&course_id=#{course.id}"

    email = 'fuyuko@example.com'

    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト ふゆこ'
      fill_in 'user[name_kana]', with: 'テスト フユコ'
      fill_in 'user[description]', with: 'テストふゆこです。'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac(Intel)', from: 'user[os]'
      select '未経験', from: 'user[experience]'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
    end

    click_button '参加する'
    assert_equal User.find_by(email: email).course_id, course.id
  end

  test 'sign up with empty description ' do
    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'foo'
      fill_in 'user[email]', with: 'siro@example.com'
      fill_in 'user[name]', with: 'テスト 四郎'
      fill_in 'user[name_kana]', with: 'テスト シロウ'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac(Intel)', from: 'user[os]'
      select '未経験', from: 'user[experience]'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
    end

    fill_stripe_element('5555 5555 5555 4444', '12 / 21', '111')

    VCR.use_cassette 'sign_up/valid-card' do
      click_button '参加する'
      assert_text '自己紹介を入力してください'
    end
  end

  test 'sign up with tag' do
    email = 'taguo@example.com'
    tag = 'タグ夫'

    visit '/users/new'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'taguo'
      fill_in 'user[email]', with: email
      fill_in 'user[name]', with: 'テスト タグ夫'
      fill_in 'user[name_kana]', with: 'テスト タグオ'
      fill_in 'user[description]', with: 'タグ登録確認用'
      fill_in 'user[password]', with: 'testtest'
      fill_in 'user[password_confirmation]', with: 'testtest'
      select '学生', from: 'user[job]'
      select 'Mac(Intel)', from: 'user[os]'
      select '未経験', from: 'user[experience]'
      check 'アンチハラスメントポリシーに同意', allow_label_click: true
      check '利用規約に同意', allow_label_click: true
      tag_input = find('.ti-new-tag-input')
      tag_input.set tag
      tag_input.native.send_keys :return
    end

    fill_stripe_element('5555 5555 5555 4444', '12 / 21', '111')

    VCR.use_cassette 'sign_up/tag', record: :once, match_requests_on: %i[method uri] do
      click_button '参加する'
      assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
      user = User.find_by(email: email)
      visit_with_auth user_path(user), 'taguo'
      assert_text 'タグ夫'
    end
  end
end
