json.announcements do
  json.array! @announcements do |announcement|
    json.partial! "api/announcements/announcement", announcement: announcement
  end
end
