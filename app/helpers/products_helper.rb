# frozen_string_literal: true

module ProductsHelper
  def unconfirmed_links_label(target)
    case target
    when 'all' then '全ての提出物を一括で開く'
    when 'unchecked', 'unchecked_all' then '未完了の提出物を一括で開く'
    when 'unchecked_no_replied' then '未返信の提出物を一括で開く'
    when 'unassigned' then '未アサインの提出物を一括で開く'
    when 'self_assigned', 'self_assigned_all' then '自分の担当の提出物を一括で開く'
    when 'self_assigned_no_replied' then '未返信の担当の提出物を一括で開く'
    else ''
    end
  end

  def not_responded_sign?(product)
    return true if product.comments.empty?

    product.self_last_commented_at.present? &&
      (product.mentor_last_commented_at.blank? ||
       product.self_last_commented_at > product.mentor_last_commented_at)
  end

  def until_next_elapsed_days(product)
    time = product.published_at || product.created_at
    elapsed_times = (Time.current - time) / 1.day
    hours = ((elapsed_times.ceil - elapsed_times) * 24).floor

    if hours < 1
      '1時間未満'
    else
      "約 #{hours} 時間"
    end
  end

  def last_commented_time_label(product)
    self_last = product.self_last_commented_at
    mentor_last = product.mentor_last_commented_at

    if self_last.present? && (mentor_last.blank? || self_last > mentor_last)
      submitter_comment_label(self_last)
    elsif mentor_last.present?
      content_tag(:div, "〜 #{l(mentor_last, format: :short)}（メンター）", class: 'a-meta')
    end
  end

  def submitter_comment_label(time)
    content_tag(:div, class: 'a-meta') do
      safe_join(["〜 #{l(time, format: :short)}（", content_tag(:strong, '提出者'), '）'])
    end
  end

  def elapsed_days_label(elapsed_days, product_deadline_day)
    if elapsed_days.zero?
      '今日提出'
    elsif elapsed_days >= product_deadline_day + 2
      "#{elapsed_days}日以上経過"
    else
      "#{elapsed_days}日経過"
    end
  end

  def filter_button_class(target, current_target)
    if current_target.blank?
      (target.end_with?('_all') ? 'is-active' : '')
    elsif target == current_target
      'is-active'
    else
      ''
    end
  end

  def filter_button_url(selected_tab, target)
    params_hash = { target: target }
    params_hash[:checker_id] = params[:checker_id] if params[:checker_id].present?

    case selected_tab
    when 'self_assigned'
      products_self_assigned_index_path(params_hash)
    else
      products_unchecked_index_path(params_hash)
    end
  end

  def filter_button_label(target)
    target.end_with?('_no_replied') ? '未返信' : '全て'
  end
end
