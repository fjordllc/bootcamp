# frozen_string_literal: true

# Userのdelegate宣言からのみ使う、非公開の委譲先オブジェクトをまとめたもの。
# ここに定義されたメソッドは全てprivateであり、Userの公開APIではない。
module UserDelegateTargets
  extend ActiveSupport::Concern

  private

  def status
    UserStatus.new(self)
  end

  def billing
    UserBilling.new(self)
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

  def github
    UserGithubAccount.new(self)
  end

  def follows
    UserFollows.new(self)
  end

  def colleagues_finder
    UserColleagues.new(self)
  end

  def region
    UserRegion.new(self)
  end

  def watcher
    UserWatcher.new(self)
  end

  def event_involvement
    UserEventInvolvement.new(self)
  end

  def regular_event_cleanup
    UserRegularEventCleanup.new(self)
  end
end
