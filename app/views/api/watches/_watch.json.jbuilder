json.id watch.id
json.watchable_id watch.watchable_id
json.watchable_type watch.watchable_type
json.user watch.user
json.edit_user matched_document(watch.watchable).user
json.created_at matched_document(watch.watchable).created_at
json.updated_at matched_document(watch.watchable).updated_at
json.url searchable_url(watch.watchable)
json.title matched_document(watch.watchable).title
json.watch_class_name watch.watchable_type.to_s.tableize.chop
json.model_name_with_i18n t("activerecord.models.#{matched_document(watch.watchable_type).to_s.tableize.singularize}")
json.summary searchable_summary(filtered_message(watch.watchable), 90)
