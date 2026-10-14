# frozen_string_literal: true

require 'test_helper'

class ReportPresetTest < ActiveSupport::TestCase
  test 'cannot register another template for the same user' do
    preset = report_presets(:report_preset1)
    duplicate = ReportPreset.new(
      user: preset.user,
      description: 'another template'
    )

    assert_not duplicate.valid?
    assert duplicate.errors.of_kind?(:user_id, :taken)
  end

  test 'database rejects duplicate templates without validation' do
    preset = report_presets(:report_preset1)
    duplicate = ReportPreset.new(
      user: preset.user,
      description: 'another template'
    )

    assert_raises ActiveRecord::RecordNotUnique do
      ReportPreset.transaction(requires_new: true) do
        duplicate.save!(validate: false)
      end
    end
  end
end
