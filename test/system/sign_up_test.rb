# frozen_string_literal: true

require 'application_system_test_case'

class SignUpTest < ApplicationSystemTestCase
  setup do
    @bot_token = Discord::Server.authorize_token
    Discord::Server.authorize_token = nil
  end

  teardown do
    Discord::Server.authorize_token = @bot_token
  end

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
      fill_in 'user[after_graduation_hope]', with: '起業したいです'
      select '学生', from: 'user[job]'
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 50', '111')

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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    fill_stripe_element('4000 0000 0000 0069', '12 / 50', '111')

    VCR.use_cassette 'sign_up/expired-card', vcr_options do
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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    fill_stripe_element('4000 0000 0000 0127', '12 / 50', '111')

    VCR.use_cassette 'sign_up/incorrect-cvc-card', vcr_options do
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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    fill_stripe_element('4000 0000 0000 0002', '12 / 50', '111')

    VCR.use_cassette 'sign_up/declined-card', vcr_options do
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
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    click_button 'アドバイザー登録'
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert User.find_by(email:).adviser?
  end

  test 'sign up as mentor' do
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
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert User.find_by(email:).mentor?
  end

  test 'sign up as a trainee who pays by invoice' do
    visit '/users/new?role=trainee_invoice_payment'

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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      first('.choices__inner').click
      find('.choices__list--dropdown').click
      find('.choices__list').click
      find('#choices--js-choices-single-select-item-choice-2').click
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    click_button '参加する'
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert User.find_by(email:).trainee?
  end

  test 'sign up as a trainee who pays by credit card' do
    visit '/users/new?role=trainee_credit_card_payment'

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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      first('.choices__inner').click
      find('.choices__list--dropdown').click
      find('.choices__list').click
      find('#choices--js-choices-single-select-item-choice-2').click
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 50', '111')

    VCR.use_cassette 'sign_up/valid-card', record: :once, match_requests_on: %i[method uri] do
      click_button '参加する'
      assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    end
    assert User.find_by(email:).trainee?
  end

  test 'sign up as a trainee who selects invoice for payment' do
    visit '/users/new?role=trainee_select_a_payment_method'

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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: '請求書払い').click
      first('.choices__inner').click
      find('.choices__list--dropdown').click
      find('.choices__list').click
      find('#choices--js-choices-single-select-item-choice-2').click
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    click_button '参加する'
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert User.find_by(email:).trainee?
  end

  test 'sign up as a trainee who selects a credit card for payment' do
    visit '/users/new?role=trainee_select_a_payment_method'

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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'クレジットカード払い').click
      first('.choices__inner').click
      find('.choices__list--dropdown').click
      find('.choices__list').click
      find('#choices--js-choices-single-select-item-choice-2').click
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 50', '111')

    click_button '参加する'
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert User.find_by(email:).trainee?
  end

  test 'form item about job seek is only displayed to students' do
    visit '/users/new'
    assert_selector "input[name='user[job_seeker]']", visible: :all

    visit '/users/new?role=adviser'
    assert has_no_selector? "input[name='user[job_seeker]']", visible: :all, wait: 5

    visit '/users/new?role=trainee_invoice_payment'
    assert has_no_selector? "input[name='user[job_seeker]']", visible: :all, wait: 5

    visit '/users/new?role=trainee_credit_card_payment'
    assert has_no_selector? "input[name='user[job_seeker]']", visible: :all, wait: 5

    visit '/users/new?role=trainee_select_a_payment_method'
    assert has_no_selector? "input[name='user[job_seeker]']", visible: :all, wait: 5
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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    fill_stripe_element('4242 4242 4242 4242', '12 / 50', '111')

    VCR.use_cassette 'sign_up/valid-card', record: :once do
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
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    click_button 'アドバイザー登録'
    assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    assert_equal User.find_by(email:).company_id, companies(:company2).id
  end

  test 'sign up as a trainee with company_id and course_id' do
    course = courses(:course1)
    company = companies(:company4)
    visit "/users/new?company_id=#{company.id}&role=trainee_invoice_payment&course_id=#{course.id}"

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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    click_button '参加する'
    assert_equal User.find_by(email:).course_id, course.id
    assert_equal User.find_by(email:).company_id, company.id
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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
    end

    fill_stripe_element('5555 5555 5555 4444', '12 / 50', '111')

    VCR.use_cassette 'sign_up/valid-card', record: :once do
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
      find('label', text: 'Mac（Intel チップ）').click
      check 'Rubyの経験あり', allow_label_click: true
      find('label', text: 'アンチハラスメントポリシーに同意').click
      find('label', text: '利用規約に同意').click
      tag_input = find('.tagify__input')
      tag_input.set tag
      tag_input.native.send_keys :return
    end

    fill_stripe_element('5555 5555 5555 4444', '12 / 50', '111')

    VCR.use_cassette 'sign_up/tag', record: :once, match_requests_on: %i[method uri] do
      click_button '参加する'
      assert_text 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
      user = User.find_by(email:)
      visit_with_auth user_path(user), 'taguo'
      assert_text 'タグ夫'
    end
  end

  test 'hidden input learning time framestable' do
    visit '/users/new'
    assert_no_selector ".form-item.a-form-label[for='user_learning_time_frames']", text: '活動時間'
  end
end
