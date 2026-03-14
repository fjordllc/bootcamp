require 'csv'

namespace :db do
  desc "Buzzテーブルの初期データ投入"
  task import_buzz_data: :environment do
    file_path = Rails.root.join('temp/data/production_buzz.csv')

    unless File.exist?(file_path)
      puts "CSVが見つかりません: (#{file_path})"
      next
    end

    now = Time.current
    list = []

    CSV.foreach(file_path, headers: true) do |row|
      list << {
        title: row['title'],
        url: row['url'],
        published_at: row['published_at'],
        created_at: now,
        updated_at: now
      }
    end

    if list.empty?
      puts "投入するデータがありません"
      next
    end

    ActiveRecord::Base.transaction do
      Buzz.delete_all
      Buzz.insert_all!(list)
    end

    puts "#{list.size}件のデータ投入が完了しました。"
  end
end
