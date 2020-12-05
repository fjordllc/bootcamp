# frozen_string_literal: true

require 'active_record/fixtures'

class NotificationMailerPreview < ActionMailer::Preview
  def came_comment
    report = Report.find(ActiveRecord::FixtureSet.identify(:report_5))
    comment = report.comments.first

    NotificationMailer.with(
      comment: comment,
      receiver: comment.receiver,
      message: "#{comment.sender.login_name}さんからコメントが届きました。"
    ).came_comment
  end

  def checked
    report = Report.find(ActiveRecord::FixtureSet.identify(:report_5))
    check = report.checks.first

    NotificationMailer.with(check: check).checked
  end

  def mentioned
    report = Report.find(ActiveRecord::FixtureSet.identify(:report_5))
    comment = report.comments.first
    receiver = report.user

    NotificationMailer.with(comment: comment, receiver: receiver).mentioned
  end

  def submitted
    product = Product.find(ActiveRecord::FixtureSet.identify(:product_3))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))
    message = "#{product.user.login_name}さんが提出しました。"

    NotificationMailer.with(
      product: product,
      receiver: receiver,
      message: message
    ).submitted
  end

  def came_answer
    question = Question.find(ActiveRecord::FixtureSet.identify(:question_2))
    answer = question.answers.first

    NotificationMailer.with(answer: answer).came_answer
  end

  def post_announcement
    announce = Announcement.find(ActiveRecord::FixtureSet.identify(:announcement_1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))

    NotificationMailer.with(
      announcement: announce,
      receiver: receiver
    ).post_announcement
  end

  def came_question
    question = Question.find(ActiveRecord::FixtureSet.identify(:question_2))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))

    NotificationMailer.with(
      question: question,
      receiver: receiver
    ).came_question
  end

  def first_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report_10))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    NotificationMailer.with(report: report, receiver: receiver).first_report
  end

  def watching_noitification
    watchable = Report.find(ActiveRecord::FixtureSet.identify(:report_1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:kimura))
    comment = Comment.find(ActiveRecord::FixtureSet.identify(:comment_4))

    NotificationMailer.with(
      watchable: watchable,
      receiver: receiver,
      comment: comment
    ).watching_notification
  end

  def retired
    sender = User.find(ActiveRecord::FixtureSet.identify(:yameo))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    NotificationMailer.with(sender: sender, receiver: receiver).retired
  end

  def trainee_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report_11))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:senpai))

    NotificationMailer.with(report: report, receiver: receiver).trainee_report
  end

  def moved_up_event_waiting_user
    event = Event.find(ActiveRecord::FixtureSet.identify(:event_3))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:hatsuno))

    NotificationMailer.with(
      event: event,
      receiver: receiver
    ).moved_up_event_waiting_user
  end
end
