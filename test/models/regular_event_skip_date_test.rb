# frozen_string_literal: true

require 'test_helper'

class RegularEventSkipDateTest < ActiveSupport::TestCase
  test 'invalid when skip_on already exists for the same regular_event' do
    regular_event = regular_events(:regular_event7)

    regular_event.regular_event_skip_dates.create!(skip_on: '2026-06-01', reason: '既存')

    duplicate_skip_date = regular_event.regular_event_skip_dates.build(skip_on: '2026-06-01', reason: '重複')

    assert_not duplicate_skip_date.valid?
    assert_includes duplicate_skip_date.errors[:skip_on], '(2026-06-01)は既に登録されています'
  end
end
