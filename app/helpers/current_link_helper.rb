module CurrentLinkHelper
  def current_link(path)
    if !path.include?("admin") && request.fullpath.include?("admin")
      false
    elsif controller_name.include?(path)
      "is-active"
    elsif path.include?("admin") && request.fullpath.include?(path)
      "is-active"
    end
  end
end
