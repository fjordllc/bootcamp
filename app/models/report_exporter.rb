# frozen_string_literal: true

class ReportExporter
  def self.export(reports, folder_path)
    Report.save_as_markdown!(reports, folder_path)
  end

  class ZipFile
    def initialize
    end

    def save_as_file!
    end
  end
end
