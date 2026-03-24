json.weekStart @week_start
json.weekEnd @week_end

json.trainees @trainees do |trainee|
  user_course_practice = UserCoursePractice.new(trainee)

  # 対象週の平日に対応する日報
  week_reports = trainee.reports
                        .where(reported_on: @week_start..@week_end)
                        .not_wip
                        .order(:reported_on)

  # 対象週にステータスが変化したlearning
  week_learnings = trainee.learnings
                          .where(updated_at: @week_start.beginning_of_day..@week_end.end_of_day)
                          .where.not(status: :unstarted)
                          .includes(:practice)

  # 現在取り組み中のプラクティスの滞留日数
  current_learning = trainee.learnings
                            .where(status: :started)
                            .order(updated_at: :desc)
                            .first

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
    json.id trainee.course.id
    json.title trainee.course.title
  end

  # 週次アクティビティ
  json.weeklyActivity do
    json.reportCount week_reports.size
    json.weekdays 5
    json.reportDates week_reports.map { |r| r.reported_on.to_s }
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
