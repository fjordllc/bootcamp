# frozen_string_literal: true

class API::UserIconUrlsController < API::BaseController
  skip_before_action :require_login_for_api

  def index
    @users = User.with_attached_avatar.where(id: ActiveStorage::Attachment.select(:record_id).where(record_type: 'User'))
  end
end
