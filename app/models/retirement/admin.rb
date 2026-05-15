# frozen_string_literal: true

# 管理者による退会用のStrategyクラス
class Retirement::Admin
  def assign_reason(_user); end

  def assign_date(user)
    user.retired_on ||= Date.current
  end

  def save_user(user)
    user.save!(validate: false)
  end

  def notification_type; end
end
