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
      else
        '参加する'
      end
    else
      '更新する'
    end
  end

  def user_github_grass_url(user)
    "https://grass-graph.moshimo.works/images/#{user.github_account}.png?background=none"
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

  def all_countries_with_subdivisions
    ISO3166::Country.all
                    .map { |country| [country.alpha2, country.subdivision_names_with_codes(I18n.locale.to_s)] }
                    .to_h
                    .to_json
  end

  def calculate_absence_days(user)
    return unless user.hibernated_at

    ((Time.zone.now - user.hibernated_at) / 86_400).floor
  end

  def remaining_days_until_automatic_retire(user)
    return unless user.hibernated_at

    ((user.automatic_retire_datetime - Time.zone.now) / 86_400).floor
  end

  def remaining_time_until_automatic_retire(user)
    if remaining_hours_until_automatic_retire(user) < 1
      "#{remaining_minutes_until_automatic_retire(user)}分"
    elsif remaining_hours_until_automatic_retire(user) < 24
      "#{remaining_hours_until_automatic_retire(user)}時間"
    else
      "#{remaining_days_until_automatic_retire(user)}日"
    end
  end

  private

  def remaining_hours_until_automatic_retire(user)
    return unless user.hibernated_at

    ((user.automatic_retire_datetime - Time.zone.now) / 3600).floor
  end

  def remaining_minutes_until_automatic_retire(user)
    return unless user.hibernated_at

    ((user.automatic_retire_datetime - Time.zone.now) / 60).floor
  end
end
