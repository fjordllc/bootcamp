# frozen_string_literal: true

module LogoHelper
  def reset_logo(company, logo_filename)
    filename = "#{logo_filename}.jpg"
    path = Rails.root.join('test/fixtures/files/companies/logos', filename)
    company.logo.attach(
      io: File.open(path, 'rb'),
      filename:,
      content_type: 'image/jpeg'
    )
  end
end
