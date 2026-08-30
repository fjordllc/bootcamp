# frozen_string_literal: true

# 画面から渡されるtarget/job文字列を、安全にUserのscopeへ解決する責務をまとめたもの。
module UserTargetScopeResolver
  extend ActiveSupport::Concern

  ALL_ALLOWED_TARGETS = %w[adviser all campaign graduate hibernated inactive job_seeking mentor retired student_and_trainee student trainee
                           year_end_party admin].freeze
  # 本来であればtarget = scope名としたいが、歴史的経緯によりtargetとscope名が一致しないものが多数あるため、名前が一致しない場合はこのハッシュを使ってscope名に変換する
  TARGET_TO_SCOPE = {
    'student_and_trainee' => :students_and_trainees,
    'student' => :students,
    'trainee' => :trainees,
    'graduate' => :graduated,
    'adviser' => :advisers,
    'admin' => :admins
  }.freeze

  class_methods do
    def notification_receiver(target)
      case target
      when 'all' then User.unretired
      when 'students' then User.admins_and_mentors.or(User.students)
      when 'job_seekers' then User.admins_and_mentors.or(User.job_seekers)
      when 'none' then User.none
      else User.none
      end
    end

    # このメソッドはユーザから送信された値をsendに渡すので、悪意のあるコードが実行される危険性がある
    # そのため、このメソッドを使用する際には安全性の確保のために以下の引数を指定すること
    # allowed_targets:　呼び出したいscope名に対応するtargetを過不足なく指定した配列。
    # default_target: targetに不正な値が渡された際、users_roleが返すスコープ名に対応するtargetを指定する。デフォルトでは:noneを指定しているため何も返さない。
    def users_role(target, allowed_targets: [], default_target: :none)
      key = (ALL_ALLOWED_TARGETS & allowed_targets).include?(target) ? target : default_target
      scope_name = TARGET_TO_SCOPE.fetch(key, key)
      send(scope_name)
    end

    # User::users_roleと同じく安全性確保のため、以下の条件を指定している。
    # allowed_job.include?(job): 存在する職業を過不足なく指定した配列の中に、jobが存在するかどうかチェック。
    def users_job(job)
      allowed_jobs = User.jobs.keys.freeze
      scope_name = allowed_jobs.include?(job) ? "job_#{job}" : 'all'
      send(scope_name)
    end
  end
end
