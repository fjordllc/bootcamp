# frozen_string_literal: true

module CompanyDecorator
  def logo_image(length)
    logo.variant(resize: "#{length}x#{length}")
  end
end
