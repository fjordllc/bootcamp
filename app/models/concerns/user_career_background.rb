# frozen_string_literal: true

# ユーザーの経歴・就業状況に関する責務をまとめたもの。
module UserCareerBackground
  extend ActiveSupport::Concern

  included do
    enum :job, { student: 0, office_worker: 2, part_time_worker: 3, vacation: 4, unemployed: 5 }, prefix: true
    enum :career_path, {
      unset: 0, job_seeking: 1, employed_via_referral: 2, employed_without_referral: 3,
      employed_non_it: 4, internal_transfer_to_programmer: 5, not_employed: 6
    }, prefix: true
    flag :experiences, %i[html_css ruby rails javascript react languages_other_than_ruby_and_javascript]
  end
end
