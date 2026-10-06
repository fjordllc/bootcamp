# frozen_string_literal: true

module McpOauth
  class PreAuthorization < Doorkeeper::OAuth::PreAuthorization
    include McpOauth::RedirectUris

    # Doorkeeper keeps validations in a per-class ivar, so subclasses must copy them.
    @validations = superclass.validations.dup

    private

    def validate_redirect_uri
      return false if redirect_uri.blank?
      return false unless Doorkeeper::OAuth::Helpers::URIChecker.valid?(redirect_uri)

      registered_redirect_uri?(client.application, redirect_uri)
    end
  end
end
