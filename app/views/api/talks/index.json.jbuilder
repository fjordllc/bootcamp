json.talks do
  json.array! @users_talks do |talk|
    json.partial! "api/talks/talk", talk: talk
  end
end

json.target t("target.#{@target}")
json.totalPages @users_talks.total_pages
