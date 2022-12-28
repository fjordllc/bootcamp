# frozen_string_literal: true

require 'active_record/fixtures'

class ActivityMailerPreview < ActionMailer::Preview
  def came_comment
    comment = Comment.find(ActiveRecord::FixtureSet.identify(:commentOfTalk))

    ActivityMailer.with(
      comment: comment,
      message: "相談部屋で#{comment.sender.login_name}さんからコメントがありました。",
      receiver: comment.receiver
    ).came_comment
  end

  def graduated
    sender = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(sender: sender, receiver: receiver).graduated
  end
end
