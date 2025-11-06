# frozen_string_literal: true

# 自動退会用のStrategyクラス
class Retirement::Auto
  def assign_reason(user)
    reason = '（休会後三ヶ月経過したため自動退会）'
    user.retire_reason = reason
  end

  def assign_date(user)
    user.retired_on = Date.current
  end

  def save_user(user)
    user.save!(validate: false)
  end

  def notification_type
    :auto_retire
  end
end
