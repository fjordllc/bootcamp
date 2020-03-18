# frozen_string_literal: true

require "test_helper"

class ParticipationTest < ActiveSupport::TestCase
  test "waited?" do
    participation = participations(:participation_2)
    participation.update(enable: true)
    assert participation.waited?
  end
end
