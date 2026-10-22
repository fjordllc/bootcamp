# frozen_string_literal: true

module Mcp
  class TokenRevoker
    def self.call(user:)
      application_ids = Doorkeeper::Application.where(mcp_client: true).select(:id)
      grants = Doorkeeper.config.access_grant_model.where(
        resource_owner_id: user.id,
        application_id: application_ids,
        revoked_at: nil
      )

      Doorkeeper.config.access_grant_model.transaction do
        # AuthorizationCodeRequest locks and checks a grant before minting its
        # access token. Revoke grants first, then query tokens so a redemption
        # that held the lock first cannot leave a newly issued token behind.
        authorization_grants = revoke_all(grants, lock: true)
        access_tokens = revoke_all(access_tokens_for(user, application_ids))
        { access_tokens:, authorization_grants: }
      end
    end

    def self.access_tokens_for(user, application_ids)
      Doorkeeper.config.access_token_model.where(
        resource_owner_id: user.id,
        application_id: application_ids,
        revoked_at: nil
      )
    end
    private_class_method :access_tokens_for

    def self.revoke_all(records, lock: false)
      count = 0
      records.find_each do |record|
        record.lock! if lock
        count += 1 if !record.revoked? && record.revoke
      end
      count
    end
    private_class_method :revoke_all
  end
end
