# frozen_string_literal: true

class RegularEvent
  class ParticipantsWatcher
    def self.call(regular_event:, target:)
      return unless regular_event.all

      new(regular_event: regular_event, target: target).call
    end

    def initialize(regular_event:, target:)
      @regular_event = regular_event
      @watchers_ids = target - @regular_event.watches.pluck(:user_id)
      @time_utc = Time.current.utc
    end

    def call
      sql = "INSERT INTO watches (watchable_type, user_id, watchable_id, created_at, updated_at) VALUES #{regular_event_watch_values};"
      ActiveRecord::Base.connection.execute(sql) unless @watchers_ids.empty?
    end

    private

    def regular_event_watch_values
      @watchers_ids.map { |id| "('RegularEvent', #{id}, #{@regular_event.id}, '#{@time_utc}', '#{@time_utc}')" }.join(',')
    end
  end
end
