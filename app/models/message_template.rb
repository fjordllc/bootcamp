# frozen_string_literal: true

class MessageTemplate
  DEFAULT_DIRECTORY = 'config/message_templates/'

  def self.load(path, params: {})
    new(path).load(params)
  end

  def initialize(path)
    @path = path
  end

  def load(params = {})
    yaml = ERB.new(read_yaml_with_embedded_ruby).result_with_hash(params)
    YAML.load(adjust_indentation(yaml))
  end

  private

  def read_yaml_with_embedded_ruby
    File.read(DEFAULT_DIRECTORY + @path)
  end

  def adjust_indentation(str)
    str.gsub(/\r\n/, "\n  ")
  end
end
