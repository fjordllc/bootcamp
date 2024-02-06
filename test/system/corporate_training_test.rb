# frozen_string_literal: true

require 'application_system_test_case'

class CorporateTrainingTest < ApplicationSystemTestCase
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

  test 'GET /corporate_training/new' do
    visit '/corporate_training/new'
    assert_equal '企業研修申し込みフォーム | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title

    fill_in '名前', with: '研修 する世'
    fill_in '企業名', with: '株式会社カンパニー'
    fill_in 'メールアドレス', with: 'corporate_training@example.com'
    fill_in '第1希望', with: '002030-01-01-08:00'
    fill_in '第2希望', with: '002030-01-02-10:00'
    fill_in '第3希望', with: '002030-01-03-12:00'
    fill_in '参加人数', with: '10'
    fill_in '研修期間', with: '1ヶ月'
    fill_in 'どこでフィヨルドブートキャンプを知りましたか？', with: 'インターネットで知った'
    fill_in 'その他伝えておきたいこと', with: 'よろしくお願いします。'
    check '下記の個人情報の取り扱いに同意する', allow_label_click: true

    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      click_button '送信'
    end
    mail = ActionMailer::Base.deliveries.last
    assert_equal '[FBC] 企業研修の申し込み', mail.subject

    assert_text 'お問い合わせを送信しました。'
    assert_no_text 'Bot対策のため送信を拒否しました。しばらくしてからもう一度送信してください。'
  end
end
