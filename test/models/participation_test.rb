# frozen_string_literal: true

require "test_helper"

class ParticipationTest < ActiveSupport::TestCase
  test "participation's enable is false when event capacity is full" do
    event = events(:event_3)
    user = users(:hajime)

    participation = event.participations.create(user: user)
    assert_equal false, participation.enable
  end

  test "participation's enable is true when event capacity is not full" do
    event = events(:event_2)
    user = users(:hajime)

    participation = event.participations.create(user: user)
    assert_equal true, participation.enable
  end
end
