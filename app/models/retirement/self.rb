# frozen_string_literal: true

# 自主退会用のStrategyクラス
class Retirement::Self
  def initialize(params)
    @params = params
  end

  def assign_reason(user)
    user.assign_attributes(@params)
  end

  def assign_date(user)
    user.retired_on = Date.current
  end

  def save_user(user)
    user.save!(context: :retirement)
  end

  def notification_type
    :retire
  end
end
