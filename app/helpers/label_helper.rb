# frozen_string_literal: true

module LabelHelper
  def bookmarkable_label(bookmarkable)
    case bookmarkable.model_name.name
    when 'Event'
      safe_join(%w[特別 イベント], tag.br)
    when 'RegularEvent'
      safe_join(%w[定期 イベント], tag.br)
    else
      bookmarkable.model_name.human
    end
  end
end
