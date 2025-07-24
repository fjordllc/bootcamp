# frozen_string_literal: true

module UserDecorator
  module ReportStatus
    # 色分けのための定数
    SUCCESS = (0..1)
    PRIMARY = (2..4)
    WARNING = (5..9)
    DANGER = (10..)

    LAST_UNCHECKED_REPORT_COUNT = 1 # unchecked_report_messageのための定数

    def user_report_count_class(count)
      case count
      when SUCCESS
        'is-success'
      when PRIMARY
        'is-primary'
      when WARNING
        'is-warning'
      else
        'is-danger'
      end
    end

    def unchecked_report_message(count, user)
      if count.zero?
        "#{user.login_name}さんの日報へ"
      elsif count == LAST_UNCHECKED_REPORT_COUNT
        "#{user.login_name}さんの未チェックの日報はこれで最後です。"
      else
        "#{user.login_name}さんの未チェックの日報が#{count}件あります。"
      end
    end
  end
end
