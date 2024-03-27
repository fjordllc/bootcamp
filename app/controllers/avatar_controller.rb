# frozen_string_literal: true

class AvatarController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  def show
    filename = params[:filename]
    path = filename.match?(/\A[a-z\d](?:[a-z\d]|-(?=[a-z\d]))*\z/i) ? Rails.root.join('storage', 'ic', 'on', 'icon', filename) : nil

    if File.file?(path)
      send_file path, disposition: 'inline'
    else
      render plain: 'File not found', status: :not_found
    end
  end
end
