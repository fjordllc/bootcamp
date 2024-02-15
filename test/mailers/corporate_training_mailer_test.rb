# frozen_string_literal: true

require 'test_helper'

class CorporateTrainingMailerTest < ActionMailer::TestCase
  test 'incoming' do
    corporate_training = CorporateTraining.new(
      company_name: '株式会社ロッカ',
      name: '駒形真幸',
      email: 'komagata@example.com',
      meeting_date1: Time.zone.parse('2030-01-01 08:00:00'),
      meeting_date2: Time.zone.parse('2030-01-02 10:00:00'),
      meeting_date3: Time.zone.parse('2030-01-03 12:00:00'),
      participants_count: 10,
      training_duration: '1ヶ月',
      how_did_you_hear: 'インターネットで知った',
      additional_information: 'よろしくお願いします。'
    )
    mail = CorporateTrainingMailer.incoming(corporate_training)
    assert_equal '[FBC] 企業研修の申し込み', mail.subject
    assert_equal ['info@lokka.jp'], mail.to
    assert_equal ['noreply@bootcamp.fjord.jp'], mail.from
    assert_equal ['komagata@example.com'], mail.reply_to
    assert_match(/企業研修の申し込み/, mail.body.to_s)
    assert_match(/駒形真幸/, mail.body.to_s)
    assert_match(/2030年01月01日\(火\)\s08:00/, mail.body.to_s)
    assert_match(/2030年01月02日\(水\)\s10:00/, mail.body.to_s)
    assert_match(/2030年01月03日\(木\)\s12:00/, mail.body.to_s)
    assert_match(/10人/, mail.body.to_s)
    assert_match(/1ヶ月/, mail.body.to_s)
    assert_match(/インターネットで知った/, mail.body.to_s)
    assert_match(/よろしくお願いします。/, mail.body.to_s)
  end
end
