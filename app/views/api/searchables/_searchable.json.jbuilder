json.title matched_document(searchable).title
json.url searchable_url(searchable)
json.model_name matched_document(searchable).class.to_s.tableize.singularize
json.model_name_with_i18n t("activerecord.models.#{matched_document(searchable).class.to_s.tableize.singularize}")
json.summury md_summury(filtered_message(searchable), 90)[3..-5]
json.updated_at l(searchable.updated_at)
json.updated_at_date_time searchable.updated_at.to_datetime
if searchable.class != Practice && searchable.class != Page
  json.login_name searchable.user.login_name
  json.user_id searchable.user.id
end

