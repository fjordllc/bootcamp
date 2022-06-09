# frozen_string_literal: true

module CompanyDecorator
  def logo_image(_length)
    rails_blob_path(logo)
  end

  def adviser_sign_up_url
    new_user_url(
      role: 'adviser',
      company_id: id,
      token: ENV['TOKEN'] || 'token'
    )
  end

  def trainee_sign_up_url
    new_user_url(
      role: 'trainee',
      company_id: id,
      token: ENV['TOKEN'] || 'token'
    )
  end
end
