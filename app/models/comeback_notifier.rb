# frozen_string_literal: true

class ComebackNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    user = payload[:user]
    User.admins_and_mentors.each do |admin_or_mentor|
      ActivityDelivery.with(sender: user, receiver: admin_or_mentor).notify(:comebacked)
    end
  end
end
