# frozen_string_literal: true

class CorporateTrainingInquiryMailerPreview < ActionMailer::Preview
  def incoming
    corporate_training_inquiry = CorporateTrainingInquiry.new(
      company_name: '株式会社カンパニー',
      name: '研修 する世',
      email: 'corporate_training_inquiry@example.com',
      meeting_date1: Time.zone.parse('2030-01-01-08:00'),
      meeting_date2: Time.zone.parse('2030-01-02-10:00'),
      meeting_date3: Time.zone.parse('2030-01-03-12:00'),
      participants_count: 10,
      training_duration: '1ヶ月',
      how_did_you_hear: 'インターネットで知った',
      additional_information: 'よろしくお願いします。'
    )
    CorporateTrainingInquiryMailer.incoming(corporate_training_inquiry)
  end
end
