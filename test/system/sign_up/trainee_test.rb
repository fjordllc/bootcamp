# frozen_string_literal: true

require 'application_system_test_case'

module SignUp
  class TraineeTest < ApplicationSystemTestCase
    setup do
      @bot_token = Discord::Server.authorize_token
      Discord::Server.authorize_token = nil
      Capybara.reset_sessions!
    end

    teardown do
      Discord::Server.authorize_token = @bot_token
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
      assert_text '研修生登録が完了しました'
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
        assert_text '研修生登録が完了しました'
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
      assert_text '研修生登録が完了しました'
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

      VCR.use_cassette 'sign_up/valid-card', record: :once, match_requests_on: %i[method uri] do
        click_button '参加する'
        assert_text '研修生登録が完了しました'
      end
      assert User.find_by(email:).trainee?
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
      assert_text 'メールからサインアップを完了させてください。'
      user = User.find_by(email:)
      assert_equal user.course_id, course.id
      assert_equal user.company_id, company.id
    end

    test 'job seeker option is hidden for trainee invoice payment' do
      visit '/users/new?role=trainee_invoice_payment'
      assert_selector 'form[name=user]'
      assert has_no_selector? "input[name='user[job_seeker]']", visible: :all
    end

    test 'job seeker option is hidden for trainee credit card payment' do
      visit '/users/new?role=trainee_credit_card_payment'
      assert_selector 'form[name=user]'
      assert has_no_selector? "input[name='user[job_seeker]']", visible: :all
    end

    test 'job seeker option is hidden for trainee select a payment method' do
      visit '/users/new?role=trainee_select_a_payment_method'
      assert_selector 'form[name=user]'
      assert has_no_selector? "input[name='user[job_seeker]']", visible: :all
    end
  end
end
