# frozen_string_literal: true

require 'active_record/fixtures'

class NotificationMailerPreview < ActionMailer::Preview
  def came_comment
    report = Report.find(ActiveRecord::FixtureSet.identify(:report5))
    comment = report.comments.first

    NotificationMailer.with(
      comment:,
      receiver: comment.receiver,
      message: "#{comment.sender.login_name}さんからコメントが届きました。"
    ).came_comment
  end

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

  def first_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report10))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    NotificationMailer.with(report:, receiver:).first_report
  end

  def watching_noitification
    watchable = Report.find(ActiveRecord::FixtureSet.identify(:report1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:kimura))
    comment = Comment.find(ActiveRecord::FixtureSet.identify(:comment4))

    NotificationMailer.with(
      watchable:,
      receiver:,
      comment:
    ).watching_notification
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

  def moved_up_event_waiting_user
    event = Event.find(ActiveRecord::FixtureSet.identify(:event3))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:hajime))

    NotificationMailer.with(
      event:,
      receiver:
    ).moved_up_event_waiting_user
  end

  def chose_correct_answer
    answer = Answer.find(ActiveRecord::FixtureSet.identify(:correct_answer2))
    receiver = answer.sender

    NotificationMailer.with(answer:, receiver:).chose_correct_answer
  end

  def consecutive_sad_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report16))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    NotificationMailer.with(report:, receiver:).consecutive_sad_report
  end

  def graduated
    sender = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    NotificationMailer.with(sender:, receiver:).graduated
  end

  def hibernated
    sender = User.find(ActiveRecord::FixtureSet.identify(:hatsuno))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    NotificationMailer.with(sender:, receiver:).hibernated
  end

  def update_regular_event
    regular_event = RegularEvent.find(ActiveRecord::FixtureSet.identify(:regular_event1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:hatsuno))

    NotificationMailer.with(regular_event:, receiver:).update_regular_event
  end
end
