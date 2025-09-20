# frozen_string_literal: true

class UnfinishedDataDestroyer
  def call(_name, _started, _finished, _id, payload)
    user = payload[:user]
    Product.where(user:).unchecked.destroy_all
    Report.where(user:).wip.destroy_all
    PairWork.where(user:).not_held.destroy_all
    user.update(career_path: 0)
  end
end
