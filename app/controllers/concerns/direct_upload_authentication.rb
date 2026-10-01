# frozen_string_literal: true

module DirectUploadAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_direct_upload_login
  end

  private

  def require_direct_upload_login
    head :unauthorized unless logged_in?
  end
end
