# frozen_string_literal: true

module RegularEventDecorator
  def holding_cycles
    regular_event_repeat_rules.map do |repeat_rule|
      holding_frequency = RegularEvent::FREQUENCY_LIST.find { |frequency| frequency[1] == repeat_rule.frequency }[0]
      holding_day_of_the_week = I18n.t('date.day_names')[repeat_rule.day_of_the_week]
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

  def upcoming_excluded_dates(from: Time.zone.today, limit: 5)
    to = from.next_year

    excluded_dates(matched_holidays(from, to), matched_skip_dates(from, to))
      .sort_by { |h| h[:date] }
      .first(limit)
  end

  def out_of_repeat_rule_skip_dates
    regular_event_skip_dates.order(skip_on: :asc).reject { |s| date_match_the_rules?(s.skip_on, regular_event_repeat_rules) }
  end

  private

  def matched_skip_dates(from, to)
    regular_event_skip_dates.where(skip_on: from..to).pluck(:skip_on, :reason)
                            .filter_map do |date, reason|
                              next unless date_match_the_rules?(date, regular_event_repeat_rules)

                              { date:, reason: }
    end
  end

  def matched_holidays(from, to)
    return [] if hold_national_holiday

    HolidayJp.between(from, to).filter_map do |h|
      next unless date_match_the_rules?(h.date, regular_event_repeat_rules)

      { date: h.date, reason: "祝日(#{h.name})のため" }
    end
  end

  def excluded_dates(holidays, skip_dates)
    (holidays + skip_dates)
      .group_by { |h| h[:date] }
      .map do |date, reasons|
        {
          date:,
          reason: reasons.map { |r| r[:reason] }.reject(&:empty?).join('、')
        }
    end
  end
end
