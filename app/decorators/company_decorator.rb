# frozen_string_literal: true

module CompanyDecorator
  def logo_image(length)
    logo.variant(combine_options: {
      resize: "#{length}x#{length}^",
      crop: "#{length}x#{length}+0+0",
      gravity: :center
    }).processed
  end
end
