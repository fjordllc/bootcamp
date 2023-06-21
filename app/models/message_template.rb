# frozen_string_literal: true

class MessageTemplate
  DEFAULT_DIRECTORY = 'config/message_templates/'

  def initialize(path)
    @path = path
  end

  def load(params = {})
    erb_str = File.read(DEFAULT_DIRECTORY + @path)
    yaml_str = ERB.new(erb_str).result_with_hash(params)
    yaml = adjust_indentation(yaml_str)
    YAML.load(yaml)
  end

  def self.load(path, params: {})
    new(path).load(params)
  end

  private

  def adjust_indentation(str)
    str.gsub(/\r\n/, "\n  ")
  end
end
