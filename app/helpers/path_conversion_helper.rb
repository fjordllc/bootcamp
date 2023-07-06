# frozen_string_literal: true

module PathConversionHelper
  def formatted_controller_path(path)
    path.tr('/', '-')
  end
end
