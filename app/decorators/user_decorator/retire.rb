# frozen_string_literal: true

module UserDecorator
  module Retire
    def retire_countdown
      ActiveSupport::Duration.build(scheduled_retire_at - Time.current) if hibernated_at?
    end

    def retire_deadline
      countdown =
        if retire_countdown.in_hours < 1
          "#{retire_countdown.in_minutes.floor}分"
        elsif retire_countdown.in_hours < 24
          "#{retire_countdown.in_hours.floor}時間"
        else
          "#{retire_countdown.in_days.floor}日"
        end

      "(自動退会まであと#{countdown})"
    end

    def countdown_danger_tag
      retire_countdown.in_days <= 7 ? 'is-danger' : ''
    end
  end
end
