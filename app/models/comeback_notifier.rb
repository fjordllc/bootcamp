# frozen_string_literal: true

class ComebacknNotifier
  def call(user)
    User.admins_and_mentors.each do |admin_or_mentor|
      ActivityDelivery.with(sender: user, receiver: admin_or_mentor).notify(:comebacked)
    end
  end
end
