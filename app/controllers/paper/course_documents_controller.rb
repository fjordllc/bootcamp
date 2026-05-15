# frozen_string_literal: true

require 'csv'

class Paper::CourseDocumentsController < PaperController
  GRANT_COURSE = 'Railsエンジニア（Reスキル講座認定）'
  CSV_FILE_NAME = 'カリキュラム一覧.csv'

  def show
    ignore_category_names = %w[就職活動（Reスキル）]
    @categories = Course.find_by(title: GRANT_COURSE).categories.where.not(name: ignore_category_names)

    respond_to do |format|
      format.html
      format.csv do
        send_data(csv_data, filename: CSV_FILE_NAME)
      end
    end
  end

  private

  def csv_data
    CSV.generate do |csv|
      csv << %w[章番号 章 章の目的 単元番号 所要時間 単元 URL].freeze
      @categories.each_with_index do |category, i|
        category.practices.each_with_index do |practice, h|
          csv << [
            i + 1,
            category.name,
            category.description,
            "#{i + 1}-#{h + 1}",
            time_format,
            practice.title,
            "https://bootcamp.fjord.jp/practices/#{practice.id}"
          ]
        end
      end
    end
  end
end
