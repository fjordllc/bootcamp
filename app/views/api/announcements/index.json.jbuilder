json.announcements do
  json.array! @announcements do |announcement|
    json.partial! "api/announcements/announcement", announcement: announcement
  end
end
json.total_pages @announcements.page(1).total_pages
