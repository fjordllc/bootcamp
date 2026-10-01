# frozen_string_literal: true

require 'test_helper'

class JobSeekingUserCountsTest < ActiveSupport::TestCase
  setup do
    @users = [users(:kimura), users(:hatsuno), users(:hajime)]
    @users.last.reports.destroy_all
    @users.last.products.delete_all
    @users.last.works.delete_all
  end

  test 'reports counts each supplied user including drafts with zero for missing records' do
    reports(:report1).update!(user_id: @users.first.id, wip: true)
    counts = JobSeekingUserCounts.new(@users.map(&:id))
    @users.each { |user| assert_equal user.reports.count, counts.reports[user.id] }
    assert_equal 0, counts.reports[users(:komagata).id]
  end

  test 'products counts each supplied user including drafts with zero for missing records' do
    assert @users.first.products.where(wip: true).exists?
    counts = JobSeekingUserCounts.new(@users.map(&:id))
    @users.each { |user| assert_equal user.products.count, counts.products[user.id] }
    assert_equal 0, counts.products[users(:mentormentaro).id]
  end

  test 'works counts each supplied user with zero for missing records' do
    counts = JobSeekingUserCounts.new(@users.map(&:id))
    @users.each { |user| assert_equal user.works.count, counts.works[user.id] }
    assert_equal 0, counts.works[users(:komagata).id]
  end

  test 'initialization uses three grouped count queries without instantiating histories' do
    queries = []
    instantiated = []
    sql_subscriber = ->(event) { queries << event.payload[:sql] if event.payload[:sql].include?('COUNT') }
    record_subscriber = ->(event) { instantiated << event.payload[:class_name] }
    ActiveSupport::Notifications.subscribed(sql_subscriber, 'sql.active_record') do
      ActiveSupport::Notifications.subscribed(record_subscriber, 'instantiation.active_record') do
        JobSeekingUserCounts.new(@users.map(&:id))
      end
    end
    assert_equal 3, queries.size
    assert(queries.all? { |sql| sql.include?('GROUP BY') && sql.include?('user_id') })
    assert_empty instantiated
  end

  test 'empty user ids return empty counts' do
    counts = JobSeekingUserCounts.new([])
    assert_empty counts.reports
    assert_empty counts.products
    assert_empty counts.works
  end
end
