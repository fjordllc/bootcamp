# frozen_string_literal: true

module UpcomingEventDecorator
  def label_style
    case original_event
    when Event
      'is-special'
    when RegularEvent
      "is-#{original_event.category}"
    end
  end

  def inner_title_style
    case original_event
    when Event
      'card-list-item__label-inner.is-sm'
    when RegularEvent
      nil
    end
  end

  def inner_title
    case original_event
    when Event
      '特別<br>イベント'
    when RegularEvent
      I18n.translate("activerecord.enums.regular_event.category.#{original_event.category}")
    end
  end
end
