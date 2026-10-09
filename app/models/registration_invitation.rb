# frozen_string_literal: true

class RegistrationInvitation
  PURPOSE = :registration_invitation
  EXPIRES_IN = 30.days
  CLAIM_KEYS = %w[role company_id course_id].freeze

  class << self
    def generate(role:, company_id: nil, course_id: nil)
      claims = { 'role' => normalize_role(role) }
      claims['company_id'] = normalize_id(company_id) unless company_id.nil?
      claims['course_id'] = normalize_id(course_id) unless course_id.nil?
      raise ArgumentError, 'Invalid registration invitation claims' unless valid_claims?(claims)

      verifier.generate(claims, purpose: PURPOSE, expires_in: EXPIRES_IN)
    end

    def verify(token)
      return unless token.is_a?(String) && token.present?

      claims = verifier.verified(token, purpose: PURPOSE)
      claims if valid_claims?(claims)
    end

    private

    def verifier
      Rails.application.message_verifier(PURPOSE)
    end

    def normalize_role(role)
      role == 'trainee' ? 'trainee_select_a_payment_method' : role
    end

    def normalize_id(id)
      id.to_s if id.is_a?(String) || id.is_a?(Integer)
    end

    def valid_claims?(claims)
      return false unless claims.is_a?(Hash) && (claims.keys - CLAIM_KEYS).empty?
      return false unless User::INVITATION_ROLES.any? { |_, role| role.to_s == claims['role'] }

      claims.except('role').values.all? { |id| id.is_a?(String) && id.match?(/\A[1-9]\d*\z/) }
    end
  end
end
