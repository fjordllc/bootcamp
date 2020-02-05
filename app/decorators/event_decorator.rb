# frozen_string_literal: true

module EventDecorator
  def period
    if start_at.to_date == end_at.to_date
      "#{l start_at} 〜 #{l end_at, format: :time_only}"
    else
      "#{l start_at} 〜 #{l end_at}"
    end
  end
end
