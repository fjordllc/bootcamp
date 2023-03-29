# frozen_string_literal: true

class RegularEvent
  class ParticipantsWatcher
    def self.call(regular_event:, target:, date_time: Time.current)
      return unless regular_event.all

      new(regular_event: regular_event, target: target, date_time: date_time).call
    end

    def initialize(regular_event:, target:, date_time:)
      @regular_event = regular_event
      @watchers_ids = target - @regular_event.watches.pluck(:user_id)
      @date_time = date_time.utc? ? date_time : date_time.utc
    end

    def call
      sql = "INSERT INTO watches (watchable_type, user_id, watchable_id, created_at, updated_at) VALUES #{regular_event_watch_values};"
      ActiveRecord::Base.connection.execute(sql) unless @watchers_ids.empty?
    end

    private

    def regular_event_watch_values
      @watchers_ids.map { |id| "('RegularEvent', #{id}, #{@regular_event.id}, '#{@date_time}', '#{@date_time}')" }.join(',')
    end
  end
end
