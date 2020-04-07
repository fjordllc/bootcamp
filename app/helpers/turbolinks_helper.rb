# frozen_string_literal: true

module TurbolinksHelper
  def turbolinks_reload_control_meta_tag
    if session[:reload_page] == true
      session[:reload_page] = false
      tag :meta, name: "turbolinks-visit-control", content: "reload"
    end
  end
end
