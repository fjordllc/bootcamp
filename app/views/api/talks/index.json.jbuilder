json.talks do
  json.array! @talks do |talk|
    json.partial! "api/talks/talk", talk: talk
  end
end
