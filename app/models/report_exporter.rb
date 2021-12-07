# frozen_string_literal: true

class ReportExporter
  def initialize(reports, folder_path)
    @reports = reports
    @folder_path = folder_path
  end

  def create
    create_reports_md
  end

  private

  def create_reports_md
    @reports.each do |report|
      File.open("#{@folder_path}/#{report.reported_on}.md", 'w') do |file|
        file.puts("# #{report.title}")
        file.puts
        file.puts(report.description)
      end
    end
    create_zip_file
  end

  def create_zip_file
    zip_filename = "#{@folder_path}/reports.zip"
    filenames = Dir.open(@folder_path, &:children).sort

    Zip::File.open(zip_filename, Zip::File::CREATE) do |zipfile|
      filenames.each do |filename|
        zipfile.add(filename, File.join(@folder_path, filename))
      end
    end
  end
end
