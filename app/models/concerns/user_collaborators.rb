# frozen_string_literal: true

module UserCollaborators
  extend ActiveSupport::Concern

  def status
    UserStatus.new(self)
  end

  def billing
    UserBilling.new(self)
  end

  def learning_time
    UserLearningTime.new(self)
  end

  def practice_progress
    UserPracticeProgress.new(self)
  end

  def coding_test_submission
    UserCodingTestSubmission.new(self)
  end

  def enrollment_period
    UserEnrollmentPeriod.new(self)
  end

  def course_grant
    UserCourseGrant.new(self)
  end

  def negative_streak_tracker
    UserNegativeStreak.new(self)
  end

  def wip_content
    UserWipContent.new(self)
  end

  def micro_report_pagination
    UserMicroReportPagination.new(self)
  end

  def hibernation
    UserHibernation.new(self)
  end

  def github
    UserGithubAccount.new(self)
  end
end
