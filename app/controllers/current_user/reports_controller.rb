# frozen_string_literal: true

class CurrentUser::ReportsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_reports
  before_action :set_export, only: %i[index]

  require 'zip'
  require 'fileutils'

  def index
    respond_to do |format|
      format.html
      format.md do
        send_reports_md
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

  def create_reports_md
    @reports_for_export.each do |report|
      File.open("tmp/exports/#{report.reported_on}.md", 'w') do |file|
        file.puts("# #{report.title}")
        file.puts
        file.puts(report.description)
      end
    end
  end

  def send_reports_md
    create_reports_md

    folderpath = 'tmp/exports'
    zip_filename = 'tmp/exports/reports.zip'
    filenames = Dir.open(folderpath, &:children)

    Zip::File.open(zip_filename, Zip::File::CREATE) do |zipfile|
      filenames.each do |filename|
        zipfile.add(filename, File.join(folderpath, filename))
      end
    end

    send_data(File.read(zip_filename), filename: '日報一覧.zip')
    FileUtils.rm(Dir.glob("#{folderpath}/*"))
  end
end
