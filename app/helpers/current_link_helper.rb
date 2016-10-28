module CurrentLinkHelper
  def current_link(path)
    if path == request.fullpath
      'is-active'
    end
  end
end
