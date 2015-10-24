module UsersHelper
  def user_find_job_assist(user)
    user.find_job_assist ? t('i_want_to_find_job_assist') : t('i_do_not_want_to_find_job_assist')
  end

  def user_tab_attrs(name)
    target = params.fetch('target', 'all')
    if target == name
      'active'
    else
      ''
    end
  end

  def user_tr_attrs(user)
    if user.active?
      { class: 'active' }
    else
      { class: 'inactive' }
    end
  end

  def user_github_url(user)
    "https://github.com/#{user.github_account}"
  end

  def user_by_type(users, type = :all)
    case type
    when :learning
      users.select(&:learning_week?)
    when :working
      users.select(&:working_week?)
    else
      users
    end
  end
end
