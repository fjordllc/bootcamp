# frozen_string_literal: true

module RegistrationInvitationHelper
  def visit_registration_invitation(role, **attributes)
    token = RegistrationInvitation.generate(role:, **attributes)
    visit new_user_path(role:, token:, **attributes)
  end
end
