# frozen_string_literal: true

require 'active_record/fixtures'

class ActivityMailerPreview < ActionMailer::Preview
  def graduated
    sender = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(sender: sender, receiver: receiver).graduated
  end

  def checked
    check = Check.find(ActiveRecord::FixtureSet.identify(:procuct2_check_komagata))
    ActivityMailer.with(receiver: check.receiver, check: check).checked
  end

  def came_answer
    question = Question.find(ActiveRecord::FixtureSet.identify(:question2))
    answer = question.answers.first

    ActivityMailer.with(answer: answer).came_answer
  end

  def post_announcement
    announce = Announcement.find(ActiveRecord::FixtureSet.identify(:announcement1))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))

    ActivityMailer.with(
      announcement: announce,
      receiver: receiver
    ).post_announcement
  end

  def three_months_after_retirement
    sender = User.find(ActiveRecord::FixtureSet.identify(:kensyuowata))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))

    ActivityMailer.with(sender: sender, receiver: receiver).three_months_after_retirement
  end

  def came_question
    receiver = User.find(ActiveRecord::FixtureSet.identify(:komagata))
    question = Question.find(ActiveRecord::FixtureSet.identify(:question1))

    ActivityMailer.with(sender: question.user, receiver: receiver, question: question).came_question
  end

  def retired
    sender = User.find(ActiveRecord::FixtureSet.identify(:yameo))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(sender: sender, receiver: receiver).retired
  end

  def mentioned
    mentionable = Comment.find(ActiveRecord::FixtureSet.identify(:comment9))
    report = Report.find(ActiveRecord::FixtureSet.identify(:report5))
    receiver = report.user

    ActivityMailer.with(mentionable: mentionable, receiver: receiver).mentioned
  end

  def create_page
    page = Page.find(ActiveRecord::FixtureSet.identify(:page4))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(sender: page.user, receiver: receiver, page: page).create_page
  end

  def submitted
    product = Product.find(ActiveRecord::FixtureSet.identify(:product15))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(product: product, receiver: receiver).submitted
  end

  def following_report
    report = Report.find(ActiveRecord::FixtureSet.identify(:report23))
    sender = User.find(ActiveRecord::FixtureSet.identify(:kensyu))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:muryou))

    ActivityMailer.with(
      report: report,
      sender: sender,
      receiver: receiver
    ).following_report
  end
end
