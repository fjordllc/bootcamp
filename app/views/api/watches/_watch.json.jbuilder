json.title matched_document(watch.watchable).title
json.id watch.id
json.watchable_type watch.watchable_type
json.watchable_id watch.watchable_id
json.created_at watch.created_at
json.updated_at watch.updated_at
json.updated_at_date_time watch.updated_at.to_datetime
json.user watch.user
json.url searchable_url(watch.watchable)
json.watch_class_name watch.watchable_type.to_s.tableize.chop  
json.summury searcher_summury(filtered_message(watch.watchable), 90)
json.model_name_with_i18n t("activerecord.models.#{matched_document(watch.watchable_type).to_s.tableize.singularize}")
