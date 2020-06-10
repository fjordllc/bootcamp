# frozen_string_literal: true

module Metric
  class User
    class << self
      def series_by_day
        (1.month.ago.to_date..Date.current)
      end

      def series_by_month
        12.times.map do |i|
          date = (Date.current << i)
          Date.new(date.year, date.month, 1)
        end.reverse
      end

      def registered_by_day
        count = ::User.
          where(
            created_at: 1.month.ago..Float::INFINITY,
            adviser: false,
            trainee: false
          ).
          group_by_day(:created_at, format: "%m/%d").count.to_h
        @@_registered_by_day ||= Metric::User.series_by_day.map do |s|
          key = s.strftime("%m/%d")
          [key, count[key] || 0]
        end.to_h
      end

      def retired_by_day
        count = ::User.
          where(retired_on: 1.month.ago..Float::INFINITY).
          group_by_day(:retired_on, format: "%m/%d").count.to_h
        @@_retired_by_day ||= Metric::User.series_by_day.map do |s|
          key = s.strftime("%m/%d")
          [key, count[key] || 0]
        end.to_h
      end

      def graduated_by_day
        count = ::User.
          where(graduated_on: 1.month.ago..Float::INFINITY).
          group_by_day(:graduated_on, format: "%m/%d").count.to_h
        @@_graduated_by_day ||= Metric::User.series_by_day.map do |s|
          key = s.strftime("%m/%d")
          [key, count[key] || 0]
        end.to_h
      end

      def registered_by_month
        count = ::User.
          where(
            created_at: 12.months.ago..Float::INFINITY,
            adviser: false,
            trainee: false
          ).
          group_by_month(:created_at, format: "%Y/%m").count.to_h
        @@_registered_by_month ||= Metric::User.series_by_month.map do |s|
          key = s.strftime("%Y/%m")
          [key, count[key] || 0]
        end.to_h
      end

      def retired_by_month
        count = ::User.
          where(retired_on: 12.months.ago..Float::INFINITY).
          group_by_month(:retired_on, format: "%Y/%m").count.to_h
        @@_retired_by_month ||= Metric::User.series_by_month.map do |s|
          key = s.strftime("%Y/%m")
          [key, count[key] || 0]
        end.to_h
      end

      def graduated_by_month
        count = ::User.
          where(graduated_on: 12.months.ago..Float::INFINITY).
          group_by_month(:graduated_on, format: "%Y/%m").count.to_h
        @@_graduated_by_month ||= Metric::User.series_by_month.map do |s|
          key = s.strftime("%Y/%m")
          [key, count[key] || 0]
        end.to_h
      end

      def by_day
        [
          { name: "入会", data: Metric::User.registered_by_day },
          { name: "退会", data: Metric::User.retired_by_day },
          { name: "卒業", data: Metric::User.graduated_by_day }
        ]
      end

      def by_month
        [
          { name: "入会", data: Metric::User.registered_by_month },
          { name: "退会", data: Metric::User.retired_by_month },
          { name: "卒業", data: Metric::User.graduated_by_month }
        ]
      end
    end
  end
end
