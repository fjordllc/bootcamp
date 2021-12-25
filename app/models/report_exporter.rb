# frozen_string_literal: true

require 'zip'

class ReportExporter
  def self.export(reports, folder_path)
    Report.save_as_markdown!(reports, folder_path)
    ZipFile.new(folder_path).save_as_file!
  end

  class ZipFile
    def initialize(folder_path)
      @path = folder_path
      @zip_filename = "#{folder_path}/reports.zip"
      @filenames = Dir.open(folder_path, &:children).sort
    end

    def save_as_file!
      Zip::File.open(@zip_filename, Zip::File::CREATE) do |zipfile|
        @filenames.each do |filename|
          zipfile.add(filename, File.join(@path, filename))
        end
      end
    end
  end
end
