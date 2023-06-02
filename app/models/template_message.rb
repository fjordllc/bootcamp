# frozen_string_literal: true

module TemplateMessage
  DEFAULT_DIRECTORY = 'config/message_templates/'

  class << self
    def load(file, hash: {})
      path = DEFAULT_DIRECTORY + file

      erb_str = File.read(path)
      yaml_str = ERB.new(erb_str).result_with_hash(hash)
      yaml = adjust_indentation(yaml_str)
      YAML.load(yaml)
    end

    private

    def adjust_indentation(str)
      str.gsub(/\r\n/, "\n  ")
    end
  end
end
