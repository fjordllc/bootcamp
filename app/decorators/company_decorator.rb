# frozen_string_literal: true

module CompanyDecorator
  def logo_image(length)
    rails_blob_path(logo)
  end
end
