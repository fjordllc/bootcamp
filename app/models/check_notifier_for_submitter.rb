# frozen_string_literal: true

class CheckNotifierForSubmitter
  def call(_name, _started, _finished, _id, payload)
    check = payload[:check]
    return unless check.receiver && check.sender != check.receiver && check.checkable_type != 'Report'

    ActivityDelivery.with(
      sender: check.sender,
      receiver: check.receiver,
      check:
    ).notify(:checked)
  end
end
