# frozen_string_literal: true

module UserDecorator
  module ReportStatus
    REPORT_COUNT_LEVELS = {
      'is-success' => 0..1,
      'is-primary' => 2..4,
      'is-warning' => 5..9
    }.freeze

    SINGLE_UNCHECKED_REPORT_COUNT = 1

    def user_report_count_class(count)
      REPORT_COUNT_LEVELS.find { |_, range| range.include?(count) }&.first || 'is-danger'
    end

    def unchecked_report_message(count, user)
      if count.zero?
        "#{user.login_name}さんの日報へ"
      elsif count == SINGLE_UNCHECKED_REPORT_COUNT
        "#{user.login_name}さんの未チェックの日報は残り1つです。"
      else
        "#{user.login_name}さんの未チェックの日報が#{count}件あります。"
      end
    end
  end
end
