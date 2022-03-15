#frozen_string_literal: true

module TalksHelper
  def unreplied_index_path(resource)
    admin_login? ? talks_unreplied_index_path : talk_path(resource)
  end
end
