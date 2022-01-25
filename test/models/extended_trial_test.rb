# frozen_string_literal: true

require 'test_helper'

class ExtendedTrialTest < ActiveSupport::TestCase
  test 'recently extended_trial' do
    later_extended_trial = extended_trials(:extended_trial2)
    earlier_extended_trial = extended_trials(:extended_trial1)

    assert_equal ExtendedTrial.recently_extended_trial, earlier_extended_trial.start_at..earlier_extended_trial.end_at
    assert_not_equal ExtendedTrial.recently_extended_trial, later_extended_trial.start_at..later_extended_trial.end_at
  end

  test 'today is extended_trial?' do
    extended_trial = extended_trials(:extended_trial1)
    assert_equal ExtendedTrial.today_is_extended_trial?, (extended_trial.start_at..extended_trial.end_at).cover?(Time.zone.today)
  end
end
