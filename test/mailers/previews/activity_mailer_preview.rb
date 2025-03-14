# frozen_string_literal: true

require 'active_record/fixtures'

class ActivityMailerPreview < ActionMailer::Preview
  def came_comment
    comment = Comment.find(ActiveRecord::FixtureSet.identify(:commentOfTalk))

    ActivityMailer.with(
      comment:,
      message: "相談部屋で#{comment.sender.login_name}さんからコメントがありました。",
      receiver: comment.receiver
    ).came_comment
  end

  def graduated
    sender = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(sender:, receiver:).graduated
  end

  def checked
    check = Check.find(ActiveRecord::FixtureSet.identify(:procuct2_check_komagata))
    ActivityMailer.with(receiver: check.receiver, check:).checked
  end

  def came_answer
    question = Question.find(ActiveRecord::FixtureSet.identify(:question2))
    answer = question.answers.first

    ActivityMailer.with(answer:).came_answer
  end

  def post_announcement
    announce = Announcement.find(ActiveRecord::FixtureSet.identify(:announcement1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))

    ActivityMailer.with(
      announcement: announce,
      receiver:
    ).post_announcement
  end

  def came_question
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))
    question = Question.find(ActiveRecord::FixtureSet.identify(:question1))

    ActivityMailer.with(sender: question.user, receiver:, question:).came_question
  end

  def retired
    sender = User.find(ActiveRecord::FixtureSet.identify(:yameo))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(sender:, receiver:).retired
  end

  def mentioned
    mentionable = Comment.find(ActiveRecord::FixtureSet.identify(:comment9))
    report = Report.find(ActiveRecord::FixtureSet.identify(:report5))
    receiver = report.user

    ActivityMailer.with(mentionable:, receiver:).mentioned
  end

  def create_page
    page = Page.find(ActiveRecord::FixtureSet.identify(:page4))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(sender: page.user, receiver:, page:).create_page
  end

  def moved_up_event_waiting_user
    event = Event.find(ActiveRecord::FixtureSet.identify(:event3))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:hatsuno))

    ActivityMailer.with(
      event:,
      receiver:
    ).moved_up_event_waiting_user
  end

  def submitted
    product = Product.find(ActiveRecord::FixtureSet.identify(:product15))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(product:, receiver:).submitted
  end

  def following_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report23))
    sender = User.find(ActiveRecord::FixtureSet.identify(:kensyu))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:muryou))

    ActivityMailer.with(
      report:,
      sender:,
      receiver:
    ).following_report
  end

  def watching_noitification
    watchable = Report.find(ActiveRecord::FixtureSet.identify(:report1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:kimura))
    comment = Comment.find(ActiveRecord::FixtureSet.identify(:comment4))
    sender = comment.user

    ActivityMailer.with(
      watchable:,
      receiver:,
      sender:,
      comment:
    ).watching_notification
  end

  def assigned_as_checker
    product = Product.find(ActiveRecord::FixtureSet.identify(:product71))
    receiver = User.find(product.checker_id)

    ActivityMailer.with(product:, receiver:).assigned_as_checker
  end

  def hibernated
    sender = User.find(ActiveRecord::FixtureSet.identify(:hatsuno))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(sender:, receiver:).hibernated
  end

  def first_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report10))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    ActivityMailer.with(report:, receiver:).first_report
  end

  def consecutive_sad_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report16))
    notification = Notification.find(ActiveRecord::FixtureSet.identify(:notification_consecutive_sad_report))
    receiver = notification.user

    ActivityMailer.with(report:, receiver:).consecutive_sad_report
  end

  def update_regular_event
    regular_event = RegularEvent.find(ActiveRecord::FixtureSet.identify(:regular_event1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:hatsuno))

    ActivityMailer.with(regular_event:, receiver:).update_regular_event
  end

  def signed_up
    sender = ActiveDecorator::Decorator.instance.decorate(User.find(ActiveRecord::FixtureSet.identify(:hajime)))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    ActivityMailer.with(sender:, receiver:, sender_roles: sender.roles_to_s).signed_up
  end

  def chose_correct_answer
    answer = Answer.find(ActiveRecord::FixtureSet.identify(:correct_answer1))
    receiver = User.find(answer.user_id)

    ActivityMailer.with(answer:, receiver:).chose_correct_answer
  end

  def no_correct_answer
    question = Question.find(ActiveRecord::FixtureSet.identify(:question1))
    receiver = User.find(question.user_id)

    ActivityMailer.with(question:, receiver:).no_correct_answer
  end

  def create_article
    article = Article.find(ActiveRecord::FixtureSet.identify(:article1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:kimura))
    user = User.find(article.user_id)

    ActivityMailer.with(article:, receiver:, sender: user).create_article
  end

  def added_work
    work = Work.find(ActiveRecord::FixtureSet.identify(:work1))
    user = User.find(work.user_id)
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    ActivityMailer.with(work:, sender: user, receiver:).added_work
  end
end
