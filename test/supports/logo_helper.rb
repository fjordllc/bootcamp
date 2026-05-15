# frozen_string_literal: true

module LogoHelper
  def reset_logo(company, logo_filename)
    filename = "companies-logos-#{logo_filename}.jpg"
    path = Rails.root.join('test/fixtures/files', filename)
    company.logo.attach(
      io: File.open(path, 'rb'),
      filename:,
      content_type: 'image/jpeg'
    )
  end
end
