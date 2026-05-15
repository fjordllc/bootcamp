# frozen_string_literal: true

require 'active_record/fixtures'

class NotificationMailerPreview < ActionMailer::Preview
  def mentioned
    report = Report.find(ActiveRecord::FixtureSet.identify(:report5))
    mentionable = Comment.find(ActiveRecord::FixtureSet.identify(:comment9))
    receiver = report.user

    NotificationMailer.with(mentionable:, receiver:).mentioned
  end

  def checked
    report = Report.find(ActiveRecord::FixtureSet.identify(:report5))
    check = report.checks.first

    NotificationMailer.with(check:).checked
  end

  def retired
    sender = User.find(ActiveRecord::FixtureSet.identify(:yameo))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    NotificationMailer.with(sender:, receiver:).retired
  end

  def trainee_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report11))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:senpai))

    NotificationMailer.with(report:, receiver:).trainee_report
  end

  def chose_correct_answer
    answer = Answer.find(ActiveRecord::FixtureSet.identify(:correct_answer2))
    receiver = answer.sender

    NotificationMailer.with(answer:, receiver:).chose_correct_answer
  end

  def graduated
    sender = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    NotificationMailer.with(sender:, receiver:).graduated
  end

  def product_update
    product = Product.find(ActiveRecord::FixtureSet.identify(:product1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    NotificationMailer.with(product:, receiver:).product_update
  end
end
