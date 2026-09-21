# frozen_string_literal: true

require 'test_helper'

class UserTargetScopeResolverTest < ActiveSupport::TestCase
  test '#users_role' do
    allowed_targets = %w[student_and_trainee mentor graduate adviser trainee year_end_party]
    resolver = UserTargetScopeResolver.new(User)

    # target引数とdefault_target引数に関して、targetとscope名が一致しているケースと一致していないケースを順にテストする
    assert_equal User.mentor, resolver.users_role('mentor', allowed_targets:, default_target: 'student_and_trainee')
    assert_equal User.graduated, resolver.users_role('graduate', allowed_targets:, default_target: 'student_and_trainee')

    assert_equal User.year_end_party, resolver.users_role('', allowed_targets:, default_target: 'year_end_party')
    assert_equal User.students_and_trainees, resolver.users_role('', allowed_targets:, default_target: 'student_and_trainee')
  end

  test '#users_role returns default_target when invalid target is passed' do
    allowed_targets = %w[student_and_trainee mentor graduate adviser trainee year_end_party]
    resolver = UserTargetScopeResolver.new(User)
    not_allowed_target = 'retired'
    assert_equal User.students_and_trainees, resolver.users_role(not_allowed_target, allowed_targets:, default_target: 'student_and_trainee')
    not_scope_name = 'destroy_all'
    assert_equal User.students_and_trainees, resolver.users_role(not_scope_name, allowed_targets:, default_target: 'student_and_trainee')
    assert_empty resolver.users_role(not_scope_name, allowed_targets:)
  end

  test '#users_role carries over conditions from the given relation' do
    company_id = users(:senpai).company_id
    scoped_relation = User.where(company_id:)
    resolver = UserTargetScopeResolver.new(scoped_relation)

    assert_equal scoped_relation.mentor, resolver.users_role('mentor', allowed_targets: %w[mentor])
  end

  test '#users_job' do
    resolver = UserTargetScopeResolver.new(User)

    assert_equal User.job_student, resolver.users_job('student')
    assert_equal User.job_office_worker, resolver.users_job('office_worker')
    assert_equal User.job_part_time_worker, resolver.users_job('part_time_worker')
    assert_equal User.job_vacation, resolver.users_job('vacation')
    assert_equal User.job_unemployed, resolver.users_job('unemployed')
  end

  test '#users_job returns all users when invalid job is passed' do
    resolver = UserTargetScopeResolver.new(User)

    assert_equal User.all, resolver.users_job('destroy_all')
  end
end
