# frozen_string_literal: true

module UsersHelper
  def user_tab_attrs(name)
    target = params.fetch('target', 'all')
    if target == name
      'active'
    else
      ''
    end
  end

  def user_github_url(user)
    "https://github.com/#{user.github_account}"
  end

  def user_submit_label(user, from)
    if from == :new
      if user.adviser?
        'アドバイザー登録'
      elsif user.mentor?
        'メンター登録'
      else
        '参加する'
      end
    else
      '更新する'
    end
  end

  def users_tags_rank(count, top3_tags_counts)
    if count == top3_tags_counts[0]
      'is-first'
    elsif count == top3_tags_counts[1]
      'is-second'
    elsif count == top3_tags_counts[2]
      'is-third'
    end
  end

  def users_tags_gradation(count, max_count)
    gradation_size = 3
    if count > (max_count / gradation_size * 2)
      'is-up'
    elsif count <= (max_count / gradation_size)
      'is-low'
    else
      'is-mid'
    end
  end

  def users_name
    User.pluck(:login_name, :id).sort
  end

  def button_label(user)
    if current_user.following?(user)
      current_user.watching?(user) ? 'コメントあり' : 'コメントなし'
    else
      'フォローする'
    end
  end

  def desc_paragraphs(user)
    max_description = user.description.length <= 200 ? user.description : "#{user.description[0...200]}..."
    max_description.split(/\n|\r\n/).map.with_index { |text, i| { id: i, text: } }
  end

  def all_countries_with_subdivisions
    ISO3166::Country.all
                    .map { |country| [country.alpha2, country.subdivision_names_with_codes(I18n.locale.to_s)] }
                    .to_h
                    .to_json
  end

  def roles_for_select
    roles = %w[all student_and_trainee inactive hibernated retired graduate adviser mentor trainee year_end_party campaign]
    roles.map { |role| [t("target.#{role}"), role] }
  end

  def jobs_for_select
    user_jobs = User.jobs.keys.map { |job| [t("activerecord.enums.user.job.#{job}"), job] }
    user_jobs.prepend(%w[全員 all])
  end

  def visible_learning_time_frames?(user)
    !user.graduated? && user.learning_time_frames.exists?
  end
end
