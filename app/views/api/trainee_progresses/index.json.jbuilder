# frozen_string_literal: true

json.weekStart @week_start
json.weekEnd @week_end

json.trainees @trainees do |trainee| # rubocop:disable Metrics/BlockLength
  user_course_practice = UserCoursePractice.new(trainee)

  # learningsを一度取得してフィルタリング
  all_learnings = trainee.learnings.reject { |l| l.status == 'unstarted' }

  week_learnings = all_learnings.select do |l|
    l.updated_at >= @week_start.beginning_of_day &&
      l.updated_at <= @week_end.end_of_day
  end

  current_learning = all_learnings
                     .select { |l| l.status == 'started' }
                     .max_by(&:updated_at)

  # 対象週の平日に対応する日報
  week_reports = trainee.reports
                        .select { |r| r.reported_on >= @week_start && r.reported_on <= @week_end && !r.wip? }
                        .sort_by(&:reported_on)

  json.id trainee.id
  json.loginName trainee.login_name
  json.longName trainee.long_name
  json.avatarUrl trainee.avatar_url

  json.company do
    if trainee.company.present?
      json.id trainee.company.id
      json.name trainee.company.name
    end
  end

  json.course do
    if trainee.course.present?
      json.id trainee.course.id
      json.title trainee.course.title
    end
  end

  # 週次アクティビティ
  json.weeklyActivity do
    json.reportCount week_reports.size
    json.weekdays 5
    json.reportDates(week_reports.map { |r| r.reported_on.to_s })
    json.practiceStatusChanges week_learnings.size
    json.practiceChanges week_learnings do |learning|
      json.practiceId learning.practice_id
      json.practiceTitle learning.practice.title
      json.status learning.status
      json.updatedAt learning.updated_at
    end
  end

  # 現在のプラクティス
  json.currentPractice do
    if current_learning
      days_on_practice = (Date.current - current_learning.updated_at.to_date).to_i
      json.id current_learning.practice_id
      json.title current_learning.practice.title
      json.daysOnPractice days_on_practice
    end
  end

  # 全体進捗
  json.overallProgress do
    json.completedPracticesCount user_course_practice.completed_required_practices.size
    json.requiredPracticesCount user_course_practice.required_practices.size
    json.completedPercentage user_course_practice.completed_percentage.round(1)
  end
end
