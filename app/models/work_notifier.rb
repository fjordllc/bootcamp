# frozen_string_literal: true

class WorkNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    work = Work.eager_load(:user).find(payload[:work].id)

    User.admins_and_mentors.each do |receiver|
      ActivityDelivery.with(work:, receiver:).notify(:added_work)
    end
  end
end
