# frozen_string_literal: true

class WorkNotifier
  def call(payload)
    work = payload[:work]

    User.admins_and_mentors.each do |receiver|
      ActivityDelivery.with(work:, receiver:).notify(:added_work)
    end
  end
end
