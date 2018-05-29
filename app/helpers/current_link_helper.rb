module CurrentLinkHelper
  def current_link(paths)
    if paths.include?(controller_path)
      "is-active"
    end
  end
end
