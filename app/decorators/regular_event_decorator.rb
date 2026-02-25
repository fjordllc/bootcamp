# frozen_string_literal: true

module RegularEventDecorator
  def holding_cycles
    regular_event_repeat_rules.map do |repeat_rule|
      holding_frequency = RegularEvent::FREQUENCY_LIST.find { |frequency| frequency[1] == repeat_rule.frequency }[0]
      holding_day_of_the_week = RegularEvent::DAY_OF_THE_WEEK_LIST.find { |day_of_the_week| day_of_the_week[1] == repeat_rule.day_of_the_week }[0]
      holding_frequency + holding_day_of_the_week
    end.join('、')
  end

  def next_holding_date
    if finished
      '開催終了'
    elsif next_event_date == Time.zone.today
      '本日開催'
    else
      "次回の開催日は #{l next_event_date} です"
    end
  end

  def holding?(date)
    return true unless HolidayJp.holiday?(date)

    hold_national_holiday
  end

  def upcoming_closed_days
    # - イベント休みの日(祝日＋任意)直近5件取得
    #    - 祝日を1年分(仮)取得
    #         - `HolidayJp.between(start_date, end_date)`
    #         - repeat_ruleに一致するもの以外は削除
    #         - 5件に絞る(5件に達したらループ終了)
    #    -  {skip_on: , reason:}に変換
    #    -  regular_event_skip_datesも5件のみ取得し{skip_on: , reason:}に変換
    # 　- mergeしてskip_onでソートして直近5件のみ取得

    # closed_days = regular_event_skip_dates.pluck(:skip_on, :reason).map do |skip_on, reason|
    #   { skip_on:, reason: }
    # end

    closed_days = regular_event_skip_dates
                  .where('skip_on >= ?', Date.current) # 過去含めるなら消す
                  .order(:skip_on)
                  .limit(5)
                  .pluck(:skip_on, :reason)
                  .map { |skip_on, reason| { skip_on:, reason: } }

    unless hold_national_holiday
      start_date = Date.current
      end_date = start_date.next_year
      holidays = HolidayJp.between(start_date, end_date) # 5件だけ取得する
      match_rules_holidays = all_scheduled_holidays(holidays: holidays) # 期間内の休日取得

      match_rules_holidays_hash = match_rules_holidays.map do |m|
        { skip_on: m.date, reason: "祝日のため(#{m.name})" }
      end

      closed_days.concat(match_rules_holidays_hash)
    end

    closed_days.sort_by { |h| h[:skip_on] }
               .take(5)
               .map { |h| "#{l(h[:skip_on], format: :long)} : #{h[:reason]}" }
  end
end
