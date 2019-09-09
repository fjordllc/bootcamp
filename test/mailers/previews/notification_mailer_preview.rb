# frozen_string_literal: true

class NotificationMailerPreview < ActionMailer::Preview
  def came_comment
    report = Report.find(ActiveRecord::FixtureSet.identify(:report_5))
    comment = report.comments.first

    NotificationMailer.came_comment(
      comment,
      comment.receiver,
      "#{comment.sender.login_name}さんからコメントが届きました。"
    )
  end

  def checked
    report = Report.find(ActiveRecord::FixtureSet.identify(:report_5))
    check = report.checks.first

    NotificationMailer.checked(check)
  end

  def mentioned
    report = Report.find(ActiveRecord::FixtureSet.identify(:report_5))
    comment = report.comments.first
    receiver = report.user

    NotificationMailer.mentioned(comment, receiver)
  end

  def submitted
    product = Product.find(ActiveRecord::FixtureSet.identify(:product_3))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))
    message = "#{product.user.login_name}さんが提出しました。"

    NotificationMailer.submitted(product, receiver, message)
  end

  def came_answer
    question = Question.find(ActiveRecord::FixtureSet.identify(:question_2))
    answer = question.answers.first

    NotificationMailer.came_answer(answer)
  end

  def post_announcement
    announce = Announcement.find(ActiveRecord::FixtureSet.identify(:announcement_1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))

    NotificationMailer.post_announcement(announce, receiver)
  end

  def came_question
    question = Question.find(ActiveRecord::FixtureSet.identify(:question_2))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))

    NotificationMailer.came_question(question, receiver)
  end

  def first_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report_10))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    NotificationMailer.first_report(report, receiver)
  end

  def watching_noitification
    watchable = Report.find(ActiveRecord::FixtureSet.identify(:report_1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:kimura))

    NotificationMailer.watching_notification(watchable, receiver)
  end

  def retired
    sender = User.find(ActiveRecord::FixtureSet.identify(:yameo))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    NotificationMailer.retired(sender, receiver)
  end

  def trainee_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report_11))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:senpai))

    NotificationMailer.trainee_report(report, receiver)
  end
end
