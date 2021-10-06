# frozen_string_literal: true

class DepressedReport
  class << self
    def reports(users, depressed_size)
      reports = nil

      depressed_size.times do |i|
        sub_query_name = "sub_reports_#{i}"
        max_reported_on = "max_reported_on_#{i}"

        if i.zero?
          reports = query(users, max_reported_on)
        else
          reports = query_after_second(reports, sub_query_name, max_reported_on)
          sub_query_name = "sub_reports_#{i + 1}" # サブクエリの名前が重複しないよう連続にしたいので、ここでindexを1すすめる
        end

        reports = query_with_sad(reports, sub_query_name, max_reported_on)
      end

      query_by_latest(reports)
    end

    private

    def query(users, max_reported_on)
      # max関数を使うと、emotionを同時に取得できないので、まずuser_idと最新のreported_onだけを取得する
      # また最後に、最新のreportsを返すため、最新のreported_onをlatest_max_reported_onとして、すべてのサブクエリに渡す
      Report.select('reports.user_id', "max(reports.reported_on) AS #{max_reported_on}", 'max(reports.reported_on) AS latest_max_reported_on')
            .where('user_id in (:user_ids)', user_ids: users.ids)
            .group(:user_id)
    end

    def query_after_second(reports, sub_query_name, max_reported_on)
      # 2回目以降は前回のサブクエリのreported_onより小さい（以前）の日付を取得することで連続したreported_onを取得する
      Report.select('reports.user_id', "max(reports.reported_on) AS #{max_reported_on}", 'latest_max_reported_on')
            .from(reports, sub_query_name)
            .joins("JOIN reports ON #{sub_query_name}.user_id = reports.user_id AND #{sub_query_name}.reported_on > reports.reported_on")
            .group('reports.user_id, latest_max_reported_on')
    end

    def query_with_sad(reports, sub_query_name, max_reported_on)
      # 直前のクエリ結果をサブクエリとして読み込み、emotion: sadで絞り込む
      Report.select('reports.*', 'latest_max_reported_on')
            .from(reports, sub_query_name)
            .joins("JOIN reports ON #{sub_query_name}.user_id = reports.user_id AND #{sub_query_name}.#{max_reported_on} = reports.reported_on")
            .where('reports.emotion': Report.emotions[:sad])
            .order('reports.reported_on': :desc)
    end

    def query_by_latest(reports)
      # 最新のlatest_max_reported_onで絞り込んで、返却する
      Report.select('reports.*')
            .from(reports, 'last_sub_query')
            .joins('JOIN reports ON last_sub_query.user_id = reports.user_id AND last_sub_query.latest_max_reported_on = reports.reported_on')
            .order('reports.reported_on': :desc)
    end
  end
end
