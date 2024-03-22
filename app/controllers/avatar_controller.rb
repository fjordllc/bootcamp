# frozen_string_literal: true

class AvatarController < ApplicationController
  def show
    filename = params[:filename]
    path = Rails.root.join('storage', 'ic', 'on', 'icon', filename)

    if File.file?(path)
      send_file path, disposition: 'inline'
    else
      render plain: 'File not found', status: :not_found
    end
  end
end
