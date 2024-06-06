# frozen_string_literal: true

class Admin::InvitationUrlController < AdminController
  def index
    @invitation_url_template = new_user_url(
      company_id: 'dummy_company_id',
      role: 'dummy_role',
      course_id: 'dummy_course_id',
      token: ENV['TOKEN'] || 'token'
    )
  end
end
