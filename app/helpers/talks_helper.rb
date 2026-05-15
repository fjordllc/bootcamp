# frozen_string_literal: true

module TalksHelper
  def action_uncompleted_index_path(talk)
    admin_login? ? talks_action_uncompleted_index_path : talk_path(talk, anchor: 'latest-comment')
  end
end
