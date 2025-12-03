# frozen_string_literal: true

module RegularEventsHelper
  def day_names_and_index_options
    I18n.t('date.day_names').map.with_index { |name, i| [name, i] }
  end
end
