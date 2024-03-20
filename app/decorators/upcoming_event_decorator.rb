# frozen_string_literal: true

module UpcomingEventDecorator
  def holding?(date)
    return true unless HolidayJp.holiday?(date)

    case self
    when Event
      true
    when RegularEvent
      hold_national_holiday
    end
  end

  def label_style
    case self
    when Event
      'is-special'
    when RegularEvent
      "is-#{category}"
    end
  end

  def inner_title_style
    case self
    when Event
      'card-list-item__label-inner.is-sm'
    when RegularEvent
      nil
    end
  end

  def inner_title
    case self
    when Event
      '特別<br>イベント'
    when RegularEvent
      I18n.translate("activerecord.enums.regular_event.category.#{category}")
    end
  end

  def translated_holding_date(date)
    case self
    when Event
      I18n.localize(start_at)
    when RegularEvent
      "#{I18n.localize(date, format: :long)} #{I18n.localize(start_at, format: :time_only)}"
    end
  end
end
