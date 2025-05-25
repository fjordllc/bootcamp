# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

module UserDecorator
  class RetireTest < ActiveDecoratorTestCase
    setup do
      @student = decorate(users(:hajime))
      @hibernationed = decorate(users(:kyuukai))
    end

    test '#retire_countdown' do
      travel_to Time.zone.local(2020, 3, 25, 9, 0, 0) do
        assert_equal 1.week, @hibernationed.retire_countdown
        assert_nil @student.retire_countdown
      end
    end

    test '#retire_deadline wihin 1 hour' do
      travel_to Time.zone.local(2020, 4, 1, 8, 1, 0) do
        assert_equal '2020年04月01日(水) 09:00 (自動退会まであと59分)', @hibernationed.retire_deadline
      end
    end

    test '#retire_deadline within 24 hours' do
      travel_to Time.zone.local(2020, 3, 31, 10, 0, 0) do
        assert_equal '2020年04月01日(水) 09:00 (自動退会まであと23時間)', @hibernationed.retire_deadline
      end
    end

    test '#retire_deadline within 1 week' do
      travel_to Time.zone.local(2020, 3, 25, 9, 0, 0) do
        assert_equal '2020年04月01日(水) 09:00 (自動退会まであと7日)', @hibernationed.retire_deadline
      end
    end

    test '#retire_deadline over 1 week' do
      travel_to Time.zone.local(2020, 1, 1, 9, 0, 0) do
        assert_equal '2020年04月01日(水) 09:00 (自動退会まであと91日)', @hibernationed.retire_deadline
      end
    end

    test '#countdown_danger_tag' do
      travel_to Time.zone.local(2020, 7, 1, 8, 1, 0) do
        assert_equal 'is-danger', @hibernationed.countdown_danger_tag
      end

      travel_to Time.zone.local(2020, 1, 1, 9, 0, 0) do
        assert_equal '', @hibernationed.countdown_danger_tag
      end
    end
  end
end
