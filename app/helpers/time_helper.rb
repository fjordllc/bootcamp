# frozen_string_literal: true

module TimeHelper
  def minute_to_span(total_minute)
    hour = (total_minute / 60).to_i
    minute = (total_minute % 60).round

    if minute.zero?
      "#{hour}時間"
    else
      "#{hour}時間#{minute}分"
    end
  end
end
