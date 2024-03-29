# frozen_string_literal: true

class UnfinishedDataDestroyer
  def call(payload)
    user = payload[:user]
    Product.where(user:).unchecked.destroy_all
    Report.where(user:).wip.destroy_all
    user.update(job_seeking: false)
  end
end
