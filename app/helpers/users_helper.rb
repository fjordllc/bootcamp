# frozen_string_literal: true

module UsersHelper # rubocop:todo Metrics/ModuleLength
  def user_activity_count(user, association, counts_by_user = nil)
    return counts_by_user.fetch(user.id).fetch(association) if counts_by_user&.key?(user.id)

    association == :comments ? user.comments.without_private_comment.size : user.public_send(association).size
  end

  def user_card_following_options(user, followings = nil)
    return {} unless followings

    following = followings[user.id]
    { is_following: following.present?, is_watching: following&.watch? || false }
  end

  def user_card_progress(user, counts_by_user = nil)
    return {} unless counts_by_user&.key?(user.id)

    counts = counts_by_user.fetch(user.id)
    percentage = user_course_practice_percentage(user, counts)
    fraction = Rails.cache.fetch("/model/user_course_practice/#{user.id}/completed_fraction") do
      "修了: #{counts[:completed]} （必須: #{counts[:completed_required]}/#{counts[:required]}）"
    end
    { percentage:, fraction: }
  end

  def user_course_practice_percentage(user, counts)
    Rails.cache.fetch("/model/user_course_practice/#{user.id}/completed_percentage") do
      counts[:completed_required].to_f / counts[:required] * UserCoursePractice::MAX_PERCENTAGE
    end
  end

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
                    .map { |country| [country.alpha2, country.subdivision_names_with_codes(I18n.locale.to_sym)] }
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

  def job_seekings_for_select
    [
      %w[全員 all],
      %w[希望する true],
      %w[希望しない false]
    ]
  end

  def payment_methods_for_select
    [
      %w[全員 all],
      %w[クレジットカード払い card],
      %w[請求書払い invoice]
    ]
  end

  def visible_learning_time_frames?(user)
    !user.graduated? && user.learning_time_frames.exists?
  end

  def event_navs(user)
    [
      { id: 'events', name: Event.model_name.human, count: user.involved_events.length, path: user_events_path(user) },
      { id: 'regular_events', name: RegularEvent.model_name.human, count: user.involved_regular_events.length, path: user_regular_events_path(user) }
    ]
  end
end
