# frozen_string_literal: true

module ProductsHelper
  def abbr_day_name(date)
    I18n.t('date.abbr_day_names')[date.wday]
  end
end
