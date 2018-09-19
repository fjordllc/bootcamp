class UserCallbacks
  def before_update(user)
    if user.graduation_changed?(from: false, to: true)
      user.graduated_at = Time.current
    elsif user.graduation_changed?(from: true, to: false)
      user.graduated_at = nil
    end
  end
end
