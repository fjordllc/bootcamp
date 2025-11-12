# frozen_string_literal: true

require 'application_system_test_case'

class InquiryTest < ApplicationSystemTestCase
  setup do
    @site_key = Recaptcha.configuration.site_key
    @secret_key = Recaptcha.configuration.secret_key

    Recaptcha.configuration.site_key = nil
    Recaptcha.configuration.secret_key = nil
  end

  teardown do
    Recaptcha.configuration.site_key = @site_key
    Recaptcha.configuration.secret_key = @secret_key
  end

  test 'GET /inquiry/new' do
    visit '/inquiry/new'
    assert_equal 'お問い合わせ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title

    fill_in '名前', with: 'ピヨルド'
    fill_in 'メールアドレス', with: 'fjord@example.com'
    fill_in 'お問い合わせ内容', with: "Bot対策が無効な状態でも\n問い合わせができるかのテストです。"
    check '下記の個人情報の取り扱いに同意する', allow_label_click: true

    perform_enqueued_jobs do
      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        click_button '送信'
      end
    end

    assert_text 'お問い合わせを送信しました。'
    assert_no_text 'Bot対策のため送信を拒否しました。しばらくしてからもう一度送信してください。'

    mail = ActionMailer::Base.deliveries.last
    assert_equal '[FBC] お問い合わせ', mail.subject
  end
end
