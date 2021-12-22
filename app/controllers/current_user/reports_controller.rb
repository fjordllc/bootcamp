# frozen_string_literal: true

class CurrentUser::ReportsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_reports
  before_action :set_export, only: %i[index]

  require 'zip'
  require 'tmpdir'

  def index
    respond_to do |format|
      format.html
      format.md do
        create_reports_md(@reports_for_export)
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def set_reports
    @reports = user.reports.list.page(params[:page])
  end

  def user
    @user ||= current_user
  end

  def set_export
    @reports_for_export = user.reports.not_wip
  end

  def create_reports_md(reports)
    Dir.mktmpdir('exports') do |dir|
      reports.each do |report|
        File.open("#{dir}/#{report.reported_on}.md", 'w') do |file|
          file.puts("# #{report.title}")
          file.puts
          file.puts(report.description)
        end
      end
      send_reports_md(dir)
    end
  end

  def send_reports_md(folder_path)
    zip_filename = "#{folder_path}/reports.zip"
    filenames = Dir.open(folder_path, &:children)

    Zip::File.open(zip_filename, Zip::File::CREATE) do |zipfile|
      filenames.each do |filename|
        zipfile.add(filename, File.join(folder_path, filename))
      end
    end
    send_data(File.read(zip_filename), filename: '日報一覧.zip')
  end
end
