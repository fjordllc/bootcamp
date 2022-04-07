# frozen_string_literal: true

module TalksHelper
  def unreplied_index_path(talk)
    admin_login? ? talks_unreplied_index_path : talk_path(talk)
  end
end
