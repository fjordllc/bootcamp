# frozen_string_literal: true

class API::UserIconUrlsController < API::BaseController
  def index
    @users = User.with_attached_avatar
  end
end
