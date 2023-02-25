# frozen_string_literal: true

class RegularEventBulkInsertQuery
  def initialize(regular_event:, target:)
    @regular_event = regular_event
    @target = target
    @time_utc = Time.current.utc
  end

  def execute
    create_participants
    create_watches
  end

  private

  def create_participants
    new_participants_ids = @target - @regular_event.participants.ids
    sql = "INSERT INTO regular_event_participations (user_id, regular_event_id, created_at, updated_at) VALUES #{participants_values(new_participants_ids)};"
    ActiveRecord::Base.connection.execute(sql) unless new_participants_ids.empty?
  end

  def create_watches
    new_watchers_ids = @target - @regular_event.watches.pluck(:user_id)
    sql = "INSERT INTO watches (watchable_type, user_id, watchable_id, created_at, updated_at) VALUES #{regular_event_watch_values(new_watchers_ids)};"
    ActiveRecord::Base.connection.execute(sql) unless new_watchers_ids.empty?
  end

  def participants_values(participants_ids)
    participants_ids.map { |id| "(#{id}, #{@regular_event.id}, '#{@time_utc}', '#{@time_utc}')" }.join(',')
  end

  def regular_event_watch_values(watchers_ids)
    watchers_ids.map { |id| "('RegularEvent', #{id}, #{@regular_event.id}, '#{@time_utc}', '#{@time_utc}')" }.join(',')
  end
end
