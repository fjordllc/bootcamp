# frozen_string_literal: true

require 'test_helper'

class UpdateEventParticipationsTest < ActiveSupport::TestCase
  test 'call' do
    event = events(:event3)
    move_up_participation = participations(:participation2)

    event.update(capacity: 2)
    UpdateEventParticipations.call(event:)

    assert_not_includes event.participations.disabled, move_up_participation
  end
end
