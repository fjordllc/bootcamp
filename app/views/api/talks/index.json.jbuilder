json.talks do
  json.array! @users_talk do |talk|
    json.partial! "api/talks/talk", talk: talk
  end
end

json.target t("target.#{@target}")
json.totalPages @users_talk.total_pages
