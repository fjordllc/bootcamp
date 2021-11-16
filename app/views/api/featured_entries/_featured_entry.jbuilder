featureable = featured_entry.featureable
json.id featured_entry.id
json.featureable_id featured_entry.featureable_id
json.modelName featured_entry.featureable_type
json.modelNameI18n t("activerecord.models.#{featureable.class.to_s.tableize.singularize}")
json.author featureable.user.name
json.authorUrl featureable.user.url
json.url polymorphic_url(featureable)
json.title featureable.title
json.created_at matched_document(featured_entry.featureable).created_at
json.updated_at matched_document(featured_entry.featureable).updated_at
json.reported_on matched_document(featured_entry.featureable).reported_on if featured_entry.featureable_type == "Report"
json.featured_entry_class_name featured_entry.featureable_type.to_s.tableize.chop
json.summary searchable_summary(filtered_message(featured_entry.featureable), 90)
