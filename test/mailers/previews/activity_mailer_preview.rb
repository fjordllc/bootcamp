# frozen_string_literal: true

require 'active_record/fixtures'

class ActivityMailerPreview < ActionMailer::Preview
  def graduated
    sender = User.find(ActiveRecord::FixtureSet.identify(:sotugyou))
    receiver = User.find(ActiveRecord::FixtureSet.identify(:mentormentaro))

    ActivityMailer.with(sender: sender, receiver: receiver).graduated
  end
end
