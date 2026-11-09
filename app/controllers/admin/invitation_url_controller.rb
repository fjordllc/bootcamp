# frozen_string_literal: true

class Admin::InvitationUrlController < AdminController
  def index
    return unless request.format.json?

    attributes = params.permit(:role, :company_id, :course_id).to_h.symbolize_keys
    unless valid_selections?(attributes)
      render json: { error: '招待の企業・ロール・コースを選択してください。' }, status: :unprocessable_entity
      return
    end

    token = RegistrationInvitation.generate(**attributes)
    render json: { url: new_user_url(**attributes, token:) }
  end

  private

  def valid_selections?(attributes)
    User::INVITATION_ROLES.any? { |_, role| role.to_s == attributes[:role] } &&
      valid_id?(attributes[:company_id]) && valid_id?(attributes[:course_id]) &&
      Company.exists?(id: attributes[:company_id]) && Course.exists?(id: attributes[:course_id])
  end

  def valid_id?(id)
    id.is_a?(String) && id.match?(/\A[1-9]\d*\z/)
  end
end
