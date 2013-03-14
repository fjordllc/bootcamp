class Settings < Settingslogic
  source File.join(Rails.root, 'config', 'settings.yml')
  namespace Rails.env
end
